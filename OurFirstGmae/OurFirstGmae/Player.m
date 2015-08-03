//
//  Player.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "Player.h"

@implementation Player

- (id)initWithPlayerId:(NSString*)playerId alias:(NSString*)alias playerState:(int)playerState {
    
    if ((self = [super init])) {
        _playerId = playerId;
        _alias = alias;
        _playerState = playerState;
    }
    return self;
}

- (void)dealloc {
    
    _playerId = nil;
    _alias = nil;
}

@end