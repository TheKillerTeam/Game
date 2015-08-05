//
//  NetworkController.h
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

typedef enum {
    
    NetworkStateNotAvailable = 0,
    NetworkStatePendingAuthentication = 1,
    NetworkStateAuthenticated = 2,
    NetworkStateConnectingToServer = 3,
    NetworkStateConnected = 4,
    NetworkStatePendingMatchStatus = 5,
    NetworkStateReceivedMatchStatus = 6,
    NetworkStatePendingMatch = 7,
    NetworkStatePendingMatchStart = 8,
    NetworkStateMatchActive = 9,
    
} NetworkState;

@class Match;

@protocol NetworkControllerDelegate

- (void)networkStateChanged:(NetworkState)networkState;
- (void)setNotInMatch;
- (void)matchStarted:(Match *)match;

@end

@interface NetworkController : NSObject

@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign, readonly) BOOL userAuthenticated;
@property (assign) id <NetworkControllerDelegate> delegate;
@property (assign, readonly) NetworkState networkState;

+ (NetworkController *)sharedInstance;
- (void)authenticateLocalUser;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController;

@end