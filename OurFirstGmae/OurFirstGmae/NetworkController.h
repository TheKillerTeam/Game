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
    
} NetworkState;

@protocol NetworkControllerDelegate

- (void)stateChanged:(NetworkState)state;

@end

@interface NetworkController : NSObject <NSStreamDelegate>

@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign, readonly) BOOL userAuthenticated;
@property (assign) id <NetworkControllerDelegate> delegate;
@property (assign, readonly) NetworkState networkState;

+ (NetworkController *)sharedInstance;
- (void)authenticateLocalUser;

@end