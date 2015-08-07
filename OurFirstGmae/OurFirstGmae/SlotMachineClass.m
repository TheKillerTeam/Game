//
//  SlotMachineClass.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/6.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "SlotMachineClass.h"
static const NSUInteger minTurn =3;



@implementation SlotMachineClass
{
    NSMutableArray *scrollLayerArray; //圖層陣列
}
//
//@property(strong,nonatomic)UIImageView *backgroundImageView;//背景
//@property(strong,nonatomic)UIImageView *coverImageView;//遮罩
//@property(strong,nonatomic)UIView *contentView;// 底層圖
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        self.backgroundImageView =[[UIImageView alloc]initWithFrame:frame];
        self.backgroundImageView.contentMode=UIViewContentModeCenter;
        [self addSubview:_backgroundImageView];//背景
        
        self.contentView=[[UIView alloc]initWithFrame:frame];
        self.contentView.backgroundColor=[UIColor blueColor];
        [self addSubview:_contentView];//底層
        
        self.coverImageView =[[UIImageView alloc]initWithFrame:frame];
        self.coverImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_contentView];//遮罩
        
        scrollLayerArray = [NSMutableArray array];//圖層陣列
        
        
    }
    return self;
    
}


-(void)setDataSource:(id<SlotMachineClassDataSource>)dataSource{
    _dataSource = dataSource;
    [self reload];
    
}


-(void)reload{
    
    if(self.dataSource){
        for(CALayer *containerLayer  in _contentView.layer.sublayers){
            [containerLayer removeFromSuperlayer];
        }
    }
    scrollLayerArray=[NSMutableArray array];
   
    

        CALayer *containLayer =[CALayer new];
        containLayer.frame = CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height);
        containLayer.masksToBounds = NO;
    containLayer.backgroundColor=[UIColor redColor].CGColor;
    
        
        
        CALayer *scrollLayer = [CALayer new];
        scrollLayer.frame = CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height);
        [containLayer addSublayer:scrollLayer];
        [_contentView.layer addSublayer:containLayer];
//        [scrollLayerArray addObject:scrollLayer];
    
    
    
    CGFloat iconUnitHeight =_contentView.frame.size.height;
     NSInteger numOfSlot = [self.dataSource numberOfslotsInMachine:self];
     NSArray *imageBox = [self.dataSource iconsForMachine:self];
     NSInteger imageNum = imageBox.count;
     NSInteger scrollIndex = -(minTurn+3)*imageNum;
    for(int j = 0 ; j>scrollIndex ;j--){
        UIImage *iconImage = [imageBox objectAtIndex:abs(j)%numOfSlot];
        CALayer *iconLayer  = [CALayer new];
        NSInteger offset = j+2+imageNum;
        iconLayer.frame=CGRectMake(0, offset*iconUnitHeight, scrollLayer.frame.size.width, iconUnitHeight);
        iconLayer.contents =(id)iconImage.CGImage;
        iconLayer.contentsScale =iconImage.scale;
        iconLayer.contentsGravity=kCAGravityCenter;
        [scrollLayer addSublayer:iconLayer];
        
        
        
    }
    
    
    
}


@end
