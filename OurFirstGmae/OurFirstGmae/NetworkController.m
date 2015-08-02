//
//  NetworkController.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "NetworkController.h"

#define SERVER_IP @"220.134.136.189"

@interface NetworkController () {
    
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    BOOL _inputOpened;
    BOOL _outputOpened;
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

- (void)setNetworkState:(NetworkState)state {
    
    _networkState = state;
    
    if (_delegate) {
        [_delegate stateChanged:_networkState];
    }
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

#pragma mark - Server communication

- (void)connect {
    
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
    
    [self setNetworkState:NetworkStateConnectingToServer];
    
    if (_inputStream != nil) {
        _inputStream.delegate = nil;
        [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream close];
        _inputStream = nil;
    }
    if (_outputStream != nil) {
        _outputStream.delegate = nil;
        [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_outputStream close];
        _outputStream = nil;
    }
}

- (void)reconnect {
    
    [self disconnect];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self connect];
    });
}

- (void)inputStreamHandleEvent:(NSStreamEvent)eventCode {
    
    switch (eventCode) {
        
        case NSStreamEventOpenCompleted:
            
            NSLog(@"Opened input stream");
            _inputOpened = YES;
            
            if (_inputOpened && _outputOpened && _networkState == NetworkStateConnectingToServer) {
                
                [self setNetworkState:NetworkStateConnected];
                // TODO: Send message to server
            }
            
        case NSStreamEventHasBytesAvailable:
            
            if ([_inputStream hasBytesAvailable]) {
                
                NSLog(@"Input stream has bytes...");
                // TODO: Read bytes
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

- (void)outputStreamHandleEvent:(NSStreamEvent)eventCode {
    
    switch (eventCode) {
        
        case NSStreamEventOpenCompleted:
            
            NSLog(@"Opened output stream");
            _outputOpened = YES;
            
            if (_inputOpened && _outputOpened && _networkState == NetworkStateConnectingToServer) {
                
                [self setNetworkState:NetworkStateConnected];
                // TODO: Send message to server
            }
            break;
            
        case NSStreamEventHasBytesAvailable:
            
            assert(NO);     // should never happen for the output stream
            break;
            
        case NSStreamEventHasSpaceAvailable:
            
            NSLog(@"Ok to send");
            // TODO: Write bytes
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
        }
    }];
}

@end