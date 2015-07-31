//
//  cropView.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/29.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "cropView.h"
#import <QuartzCore/QuartzCore.h>
#import "clothCell.h"

#define TABLEVIEW_HEIGHT 100
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
 
    
    uniformArray = [NSArray new];
    
     uniformArray = @[[UIImage imageNamed:@"play6.jpg"],[UIImage imageNamed:@"play7.jpg"]];
    self.clipsToBounds =YES;

    
    int radius = 70;
    mask=[[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width/2, self.frame.size.height/2-270, 2*radius, 2*radius)];
    mask.center= CGPointMake(self.frame.size.width/2, self.frame.size.height/2-200);
    mask.layer.cornerRadius=radius;
    mask.layer.masksToBounds=YES;
    mask.clipsToBounds=YES;
   
    
    
    mask.layer.borderWidth=5;
    mask.layer.borderColor=[UIColor redColor].CGColor;
    mask.layer.backgroundColor=[UIColor whiteColor].CGColor;
    
    [self addSubview:mask];
 
    
    
    
    imageView=[UIImageView new];
    imageView.frame = CGRectMake(mask.frame.size.width/2, mask.frame.size.height/2, 2*radius ,2*radius);
    imageView.center=CGPointMake(mask.frame.size.width/2, mask.frame.size.height/2);
    [mask addSubview:imageView];
    
    
    
    
    UIPinchGestureRecognizer *scaleGes = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(scaleImage:)];
    [mask addGestureRecognizer:scaleGes];
    
    
    UIPanGestureRecognizer *moveGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveImage:)];
    [moveGes setMinimumNumberOfTouches:1];
    [moveGes setMaximumNumberOfTouches:1];
    [mask addGestureRecognizer:moveGes];
    
    

    
    clothFrame  = [UITableView new];
    clothFrame.backgroundColor = [UIColor whiteColor];
    [clothFrame.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    clothFrame.transform = CGAffineTransformMakeRotation(M_PI/-2);
    clothFrame.showsVerticalScrollIndicator = YES;
    clothFrame.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 150);
    clothFrame.rowHeight = self.frame.size.width/4;
    NSLog(@"%f,%f,%f,%f",clothFrame.frame.origin.x,clothFrame.frame.origin.y,clothFrame.frame.size.width,clothFrame.frame.size.height);
    clothFrame.delegate = self;
    clothFrame.dataSource = self;
    [self addSubview:clothFrame];
    
    
    _clothImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 300)];
    _clothImage.backgroundColor = [UIColor redColor];
    CGRect frame = _clothImage.frame;
    frame.origin.y = mask.center.y;
    frame.origin.x = self.frame.size.width/2-_clothImage.frame.size.width/2;
    _clothImage.frame = frame;
    
    
    [self insertSubview:_clothImage belowSubview:mask];
    
    
    
    
    
    
    
    
    
    
    
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return uniformArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"cellID";
    clothCell *cell =[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell ==nil){
        cell = [[clothCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if(tableView == clothFrame){
       
        UIImage *uniform = [uniformArray objectAtIndex:indexPath.row];
        cell.imageView.image = uniform;
        cell.imageView.transform=CGAffineTransformMakeRotation(M_PI/2);

    
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(imageView.image !=nil){
    _clothImage.image = uniformArray[indexPath.row];
    }
    
    
    
    
}

@end
