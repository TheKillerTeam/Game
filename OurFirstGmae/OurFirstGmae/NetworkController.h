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
    
    NetworkStateNotAvailable,
    NetworkStatePendingAuthentication,
    NetworkStateAuthenticated,
    NetworkStateConnectingToServer,
    NetworkStateConnected,
    NetworkStatePendingMatchStatus,
    NetworkStateReceivedMatchStatus,
    NetworkStatePendingMatch,
    NetworkStatePendingMatchStart,
    NetworkStateMatchActive,
    
} NetworkState;

@class Match;

@protocol NetworkControllerDelegate

- (void)networkStateChanged:(NetworkState)state;
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