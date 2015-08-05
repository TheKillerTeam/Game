//
//  playerInfoViewController.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/28.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol playerInfoViewControllerDelegate<NSObject>

-(void)transImage:(UIImage*)image;

@end

@interface playerInfoViewController : UIViewController

@property(nonatomic,weak)id<playerInfoViewControllerDelegate>delegate;

//Eric
@property (nonatomic, assign) int playerCounts;

@end
