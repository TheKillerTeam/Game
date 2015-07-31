//
//  cropView.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/29.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface cropView : UIView<UITableViewDataSource,UITableViewDelegate>
{
      UIView *mask;
    UIImageView *imageView;
    UITableView *clothFrame;
    NSArray *uniformArray ;

}
@property(nonatomic,retain)IBOutlet UIImage*image;
@property(retain,nonatomic)UIImageView *clothImage;
-(void)step;
@end
