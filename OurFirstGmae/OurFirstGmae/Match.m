//
//  Match.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "Match.h"

@implementation Match

- (id)initWithState:(MatchState)matchState players:(NSArray*)players {
    
    if ((self = [super init])) {
        
        _matchState = matchState;
        _players = players;
    }
    return self;
}

- (void)dealloc {
    
    _players = nil;
}

@end