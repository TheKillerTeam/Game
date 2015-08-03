//
//  Player.h
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property (nonatomic, strong) NSString *playerId;
@property (nonatomic, strong) NSString *alias;
@property (nonatomic, assign) int playerState;

- (id)initWithPlayerId:(NSString*)playerId alias:(NSString*)alias playerState:(int)playerState;

@end