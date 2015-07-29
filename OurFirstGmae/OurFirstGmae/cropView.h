//
//  cropView.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/29.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface cropView : UIView
{
      UIView *mask;
    UIImageView *imageView;

}
@property(nonatomic,retain)IBOutlet UIImage*image;
-(void)step;
@end
