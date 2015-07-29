//
//  cropView.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/29.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "cropView.h"
#import <QuartzCore/QuartzCore.h>
@implementation cropView
{
    CGFloat lastScale,lastX,lastY;
  
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)step{
 
    self.clipsToBounds =YES;

    
    int radius = 80;
    mask=[[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-80, self.frame.size.height/2-130, 2*radius, 2*radius)];
    mask.layer.cornerRadius=radius;
    mask.layer.masksToBounds=YES;
    mask.clipsToBounds=YES;
   
    
    
    mask.layer.borderWidth=5;
    mask.layer.borderColor=[UIColor redColor].CGColor;
    mask.layer.backgroundColor=[UIColor whiteColor].CGColor;
    
    [self addSubview:mask];
 
    
    
    
    imageView=[UIImageView new];
    imageView.frame = CGRectMake(0, 0, 100 ,100);
    imageView.layer.masksToBounds=YES;
    [mask addSubview:imageView];
    
    
    
    
    
    
    
    UIPinchGestureRecognizer *scaleGes = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(scaleImage:)];
    [mask addGestureRecognizer:scaleGes];
    
    
    UIPanGestureRecognizer *moveGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveImage:)];
    [moveGes setMinimumNumberOfTouches:1];
    [moveGes setMaximumNumberOfTouches:1];
    [mask addGestureRecognizer:moveGes];
    
    
    
    
    
    
    
}
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        [self step];
    }
    return self;
}


-(void)scaleImage:(UIPinchGestureRecognizer*)sender{
    
    if([sender state]==UIGestureRecognizerStateBegan){
        lastScale = 1.0;
        return;
    }
    
    CGFloat scale = [sender scale]/lastScale;
    CGAffineTransform currentTransform = imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [imageView setTransform:newTransform];
    
    lastScale = [sender scale];
    
    
    
}
-(void)moveImage:(UIPanGestureRecognizer*)sender{
    
    CGPoint translatedPoint = [sender translationInView:self];
    
    if([sender state] == UIGestureRecognizerStateBegan) {
        lastX=0.0;
        lastY= 0.0;
    }
    
    CGAffineTransform trans = CGAffineTransformMakeTranslation(translatedPoint.x - lastX, translatedPoint.y - lastY);
    CGAffineTransform newTransform = CGAffineTransformConcat(imageView.transform, trans);
    lastX = translatedPoint.x;
    lastY = translatedPoint.y;
    
    imageView.transform = newTransform;
}

-(void)setImage:(UIImage*)image1{
   
    imageView.image=image1;
    
    
    
}


@end
