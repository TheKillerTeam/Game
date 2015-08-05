//
//  TestGameViewController.h
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Match;

@protocol TestGameViewControllerDelegate <NSObject>

- (void)TGVCsetNotInMatch;

@end

@interface TestGameViewController : UIViewController

@property (nonatomic, strong) Match *match;
@property (nonatomic, weak) id<TestGameViewControllerDelegate> delegate;

@end
