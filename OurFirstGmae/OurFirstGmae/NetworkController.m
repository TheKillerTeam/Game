//
//  NetworkController.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "NetworkController.h"
#import "MessageWriter.h"
#import "MessageReader.h"
#import "Match.h"
#import "Player.h"

#define SERVER_IP @"220.134.136.189"
#define PLAYER_IMAGE_DEFAULT @"news2.jpg"

typedef enum {
    
    MessagePlayerConnected = 0,     //to Server
    MessageNotInMatch = 1,              //from Server
    MessageStartMatch = 2,          //to Server
    MessageMatchStarted = 3,            //from Server
    MessagePlayerImageUpdated = 4,  //to Server
    MessagePlayerSendChat = 5,      //to Server
    MessageUpdateChat = 6,             //from Server
    
} MessageType;

//TODO:continue to add sendChat, updateChat function & add receiver, sender on Server

@interface NetworkController () <NSStreamDelegate, GKMatchmakerViewControllerDelegate> {
    
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    BOOL _inputOpened;
    BOOL _outputOpened;
    NSMutableData *_outputBuffer;
    BOOL _okToWrite;
    NSMutableData *_inputBuffer;
    UIViewController *_presentingViewController;
    GKMatchmakerViewController *_mmvc;
}

@end

@implementation NetworkController

#pragma mark - Helpers

static NetworkController *sharedController = nil;

+ (NetworkController *) sharedInstance {
    
    if (!sharedController) {
        
        sharedController = [[NetworkController alloc] init];
    }
    return sharedController;
}

- (BOOL)isGameCenterAvailable {
    
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (void)setNetworkState:(NetworkState)networkState {
    
    _networkState = networkState;
    
    if (_delegate) {
        [_delegate networkStateChanged:_networkState];
    }
}

- (void)dismissMatchmaker {
    
    [_presentingViewController dismissViewControllerAnimated:YES completion:nil];
    _mmvc = nil;
    _presentingViewController = nil;
}

#pragma mark - Init

- (id)init {
    
    if ((self = [super init])) {
        
        [self setNetworkState:_networkState];
        _gameCenterAvailable = [self isGameCenterAvailable];
        
        if (_gameCenterAvailable) {
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

#pragma mark - Message sending / receiving

- (void)sendData:(NSData *)data {
    
    if (_outputBuffer == nil) return;
    
    int dataLength = (int)data.length;
    dataLength = htonl(dataLength);
    
    [_outputBuffer appendBytes:&dataLength length:sizeof(dataLength)];
    [_outputBuffer appendData:data];
    
    if (_okToWrite) {
        
        [self writeChunk];
        NSLog(@"Wrote message");
        
    } else {
        
        NSLog(@"Queued message");
    }
}

- (void)sendPlayerConnected:(BOOL)continueMatch {
    
    [self setNetworkState:NetworkStatePendingMatchStatus];
    
    MessageWriter * writer = [MessageWriter new];
    
    [writer writeByte:MessagePlayerConnected];
    
    UIImage *img = [UIImage imageNamed:PLAYER_IMAGE_DEFAULT];
    NSData *imageData = UIImageJPEGRepresentation(img, 1.0f);
    NSString *base64string = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [writer writeString:base64string];
    
    [writer writeString:[GKLocalPlayer localPlayer].playerID];
    [writer writeString:[GKLocalPlayer localPlayer].alias];
    [writer writeByte:continueMatch];
    
    [self sendData:writer.data];
}

- (void)sendStartMatch:(NSArray *)players {
    
    [self setNetworkState:NetworkStatePendingMatchStart];
    
    MessageWriter * writer = [MessageWriter new];
    
    [writer writeByte:MessageStartMatch];
    
    [writer writeByte:players.count];
    
    for(NSString *playerId in players) {
        
        [writer writeString:playerId];
    }
    [self sendData:writer.data];
}

- (void)sendUpdatePlayerImage:(UIImage *)image {
    
    MessageWriter * writer = [MessageWriter new];
    
    [writer writeByte:MessagePlayerImageUpdated];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSString *base64string = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [writer writeString:base64string];
    
    [writer writeString:[GKLocalPlayer localPlayer].playerID];
    
    [self sendData:writer.data];
}

- (void)sendChat:(NSString *)chat withChatType:(ChatType)chatType{
    
    MessageWriter * writer = [MessageWriter new];
    
    [writer writeByte:MessagePlayerSendChat];
    
    [writer writeString:chat];
    [writer writeByte:chatType];
    [writer writeString:[GKLocalPlayer localPlayer].playerID];
    
    [self sendData:writer.data];
}

- (void)processMessage:(NSData *)data {
    
    MessageReader * reader = [[MessageReader alloc] initWithData:data];
    
    unsigned char msgType = [reader readByte];
    
    if (msgType == MessageNotInMatch) {
        
        [self setNetworkState:NetworkStateReceivedMatchStatus];
        
    }else if (msgType == MessageMatchStarted) {
        
        [self setNetworkState:NetworkStateMatchActive];
        [self dismissMatchmaker];
        unsigned char matchState = [reader readByte];
        NSMutableArray *players = [NSMutableArray array];
        unsigned char numPlayers = [reader readByte];
        
        for (unsigned char i = 0; i < numPlayers; ++i) {
            
            NSString *playerImageString = [reader readString];
            NSString *playerId = [reader readString];
            NSString *alias = [reader readString];
            int playerState = [reader readByte];
            int playerTeam = [reader readByte];
            Player *player = [[Player alloc] initWithPlayerImageString:playerImageString playerId:playerId alias:alias playerState:playerState playerTeam:playerTeam];
            [players addObject:player];
        }
        Match *match = [[Match alloc] initWithState:matchState players:players];
        [_delegate matchStarted:match];
        
    }else if (msgType == MessageUpdateChat) {
        
        NSString *chat = [reader readString];
        NSString *playerId = [reader readString];
        [self.delegate updateChat:chat withPlayerId:playerId];
    }
}

#pragma mark - Server communication

- (void)connect {
    
    _inputBuffer = [NSMutableData data];
    _outputBuffer = [NSMutableData data];
    
    [self setNetworkState:NetworkStateConnectingToServer];
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)SERVER_IP, 1955, &readStream, &writeStream);
    
    _inputStream = (__bridge NSInputStream *)readStream;
    _outputStream = (__bridge NSOutputStream *)writeStream;
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    [_outputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
}

- (void)disconnect {
    
    [self setNetworkState:NetworkStateAuthenticated];
    
    if (_inputStream != nil) {
        
        _inputStream.delegate = nil;
        [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream close];
        _inputStream = nil;
        _inputBuffer = nil;
    }
    if (_outputStream != nil) {
        
        _outputStream.delegate = nil;
        [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_outputStream close];
        _outputStream = nil;
        _outputBuffer = nil;
    }
}

- (void)reconnect {
    
    [self disconnect];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self connect];
    });
}

- (void)checkForMessages {
    
    while (true) {
        
        if (_inputBuffer.length < sizeof(int)) {
            
            return;
        }
        int msgLength = *((int *) _inputBuffer.bytes);
        msgLength = ntohl(msgLength);
        
        if (_inputBuffer.length < msgLength) {
            
            return;
        }
        NSData * message = [_inputBuffer subdataWithRange:NSMakeRange(4, msgLength)];
        [self processMessage:message];
        
        int amtRemaining = (int)_inputBuffer.length - msgLength - sizeof(int);
        
        if (amtRemaining == 0) {
            
            _inputBuffer = [NSMutableData new];
            
        } else {
            
            NSLog(@"Creating input buffer of length %d", amtRemaining);
            _inputBuffer = [[NSMutableData alloc] initWithBytes:_inputBuffer.bytes+4+msgLength length:amtRemaining];
        }
    }
}

- (void)inputStreamHandleEvent:(NSStreamEvent)eventCode {
    
    switch (eventCode) {
        
        case NSStreamEventOpenCompleted:
            
            NSLog(@"Opened input stream");
            _inputOpened = YES;
            
            if (_inputOpened && _outputOpened && _networkState == NetworkStateConnectingToServer) {
                
                [self setNetworkState:NetworkStateConnected];
                //Send message to server
                [self sendPlayerConnected:true];
            }
            
        case NSStreamEventHasBytesAvailable:
            
            if ([_inputStream hasBytesAvailable]) {
                
                NSLog(@"Input stream has bytes...");
                //Read bytes
                NSInteger       bytesRead;
                uint8_t         buffer[32768];
                
                bytesRead = [_inputStream read:buffer maxLength:sizeof(buffer)];
                
                if (bytesRead == -1) {
                    
                    NSLog(@"Network read error");
                    
                } else if (bytesRead == 0) {
                    
                    NSLog(@"No data read, reconnecting");
                    [self reconnect];
                    
                } else {
                    
                    NSLog(@"Read %d bytes", (int)bytesRead);
                    [_inputBuffer appendData:[NSData dataWithBytes:buffer length:bytesRead]];
                    [self checkForMessages];
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            
            assert(NO); // should never happen for the input stream
            break;
            
        case NSStreamEventErrorOccurred:
            
            NSLog(@"Stream open error, reconnecting");
            [self reconnect];
            break;
            
        case NSStreamEventEndEncountered:
            
            // ignore
            break;
            
        default:
            
            assert(NO);
            break;
    }
}

- (BOOL)writeChunk {
    
    int amtToWrite = MIN((int)_outputBuffer.length, 1024);
    
    if (amtToWrite == 0) return FALSE;
    
    NSLog(@"Amt to write: %d/%d", amtToWrite, (int)_outputBuffer.length);
    
    int amtWritten = [_outputStream write:_outputBuffer.bytes maxLength:amtToWrite];
    
    if (amtWritten < 0) {
        
        [self reconnect];
    }
    int amtRemaining = (int)_outputBuffer.length - amtWritten;
    
    if (amtRemaining == 0) {
        
        _outputBuffer = [NSMutableData data];
        
    } else {
        
        NSLog(@"Creating output buffer of length %d", amtRemaining);
        _outputBuffer = [NSMutableData dataWithBytes:_outputBuffer.bytes+amtWritten length:amtRemaining];
    }
    NSLog(@"Wrote %d bytes, %d remaining.", amtWritten, amtRemaining);
    _okToWrite = FALSE;
    return TRUE;
}

- (void)outputStreamHandleEvent:(NSStreamEvent)eventCode {
    
    switch (eventCode) {
        
        case NSStreamEventOpenCompleted:
            
            NSLog(@"Opened output stream");
            _outputOpened = YES;
            
            if (_inputOpened && _outputOpened && _networkState == NetworkStateConnectingToServer) {
                
                [self setNetworkState:NetworkStateConnected];
                //Send message to server
                [self sendPlayerConnected:true];
            }
            break;
            
        case NSStreamEventHasBytesAvailable:
            
            assert(NO);     // should never happen for the output stream
            break;
            
        case NSStreamEventHasSpaceAvailable:
            
            NSLog(@"Ok to send");
            //Write bytes
            BOOL wroteChunk = [self writeChunk];
            
            if (!wroteChunk) {
                
                _okToWrite = TRUE;
            }
            
            break;
            
        case NSStreamEventErrorOccurred:
            
            NSLog(@"Stream open error, reconnecting");
            [self reconnect];
            break;
            
        case NSStreamEventEndEncountered:
            
            // ignore
            break;
            
        default:
            
            assert(NO);
            break;
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        if (aStream == _inputStream) {
            
            [self inputStreamHandleEvent:eventCode];
            
        } else if (aStream == _outputStream) {
            
            [self outputStreamHandleEvent:eventCode];
        }
    });
}

#pragma mark - Authentication

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !_userAuthenticated) {
        
        NSLog(@"Authentication changed: player authenticated.");
        [self setNetworkState:NetworkStateAuthenticated];
        _userAuthenticated = TRUE;
        [self connect];
        
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && _userAuthenticated) {
        
        NSLog(@"Authentication changed: player not authenticated");
        _userAuthenticated = FALSE;
        [self disconnect];
        [self setNetworkState:NetworkStateNotAvailable];
    }
    
}

- (void)authenticateLocalUser {
    
    if (!_gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");

    [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *viewController, NSError *error){
        
        if (viewController != nil) {
            
            UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            [rootVC presentViewController:viewController animated:YES completion:nil];
        
        }else if ([GKLocalPlayer localPlayer].isAuthenticated) {
            
            NSLog(@"Already authenticated");
            
        }else {
            
            NSLog(@"local player not authenticated");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game center login required" message:@"please login game center to continue" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            [rootVC presentViewController:alert animated:YES completion:nil];
        }
    }];
}

#pragma mark - Matchmaking

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController {
    
    if (!_gameCenterAvailable) return;
    
    [self setNetworkState:NetworkStatePendingMatch];
    
    _presentingViewController = viewController;
    [_presentingViewController dismissViewControllerAnimated:NO completion:nil];
    
    if (FALSE) {
        
        // TODO: Will add code here later!
        
    } else {
        
        GKMatchRequest *request = [GKMatchRequest new];
        request.minPlayers = minPlayers;
        request.maxPlayers = maxPlayers;
        
        _mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
        _mmvc.hosted = YES;
        _mmvc.matchmakerDelegate = self;
        
        [_presentingViewController presentViewController:_mmvc animated:YES completion:nil];
    }
}

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    
    NSLog(@"matchmakerViewControllerWasCancelled");
    [self setNetworkState:NetworkStateReceivedMatchStatus];
    [self dismissMatchmaker];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError: %@", error.localizedDescription);
    [self setNetworkState:NetworkStateReceivedMatchStatus];
    [self dismissMatchmaker];
}

// Players have been found for a server-hosted game, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindPlayers:(NSArray *)playerIDs {
    
    NSLog(@"didFindPlayers");
    
    //把自己的playerID也加進 playerIDs
    NSMutableArray *tmpPlayerIDs = [NSMutableArray arrayWithArray:playerIDs];
    [tmpPlayerIDs insertObject:[GKLocalPlayer localPlayer].playerID atIndex:0];
    playerIDs = [NSArray arrayWithArray:tmpPlayerIDs];
    
    for (NSString *playerID in playerIDs) {
        
        NSLog(@"%@", playerID);
    }
    if (_networkState == NetworkStatePendingMatch) {
        
        [self dismissMatchmaker];
        //Send message to server to start match, with given player Ids
        [self sendStartMatch:playerIDs];
    }
}

// An invited player has accepted a hosted invite.  Apps should connect through the hosting server and then update the player's connected state (using setConnected:forHostedPlayer:)
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didReceiveAcceptFromHostedPlayer:(NSString *)playerID __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0) {
    
    NSLog(@"didReceiveAcceptFromHostedPlayer");
}

@end