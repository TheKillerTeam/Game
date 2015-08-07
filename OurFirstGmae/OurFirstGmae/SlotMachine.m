//
//  SlotMachine.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/6.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "SlotMachine.h"
#import "SlotMachineClass.h"
@interface SlotMachine ()
{
    SlotMachineClass *slotClass;
    UIImageView *iconImageView;
    UIImageView *container;
    UILabel *jobNameLb;
    
    
}
@property (strong,nonatomic)NSArray *slotIcon;
@property (strong,nonatomic)NSArray *iconText;
@property (weak,nonatomic)UIButton *startBtn;
@property (weak,nonatomic)NSString *jobName;
@end

@implementation SlotMachine

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.slotIcon = [NSArray arrayWithObjects:[UIImage imageNamed:@"Batman"],[UIImage imageNamed:@"Mario"],[UIImage imageNamed:@"Doraemon"],[UIImage imageNamed:@"Nobi Nobita"], nil];
    self.iconText =@[@"警察",@"殺手",@"平民",@"超人"];
    
    
    slotClass = [[SlotMachineClass alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height/5)];
    slotClass.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/3);
//    slotClass.backgroundColor=[UIColor redColor];

    
    slotClass.delegate=self;
    slotClass.dataSource=self;
   
    [self.view addSubview:slotClass];
    
    _startBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.startBtn setTitle:@"Start" forState:UIControlStateNormal];
    [self.startBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    

    [self.startBtn setFrame:CGRectMake(0, 0, slotClass.frame.size.width/2, slotClass.frame.size.height/2)];
    [self.startBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    self.startBtn.center = self.view.center;
    
    [self.view addSubview:_startBtn];
    
    container= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, slotClass.frame.size.width, slotClass.frame.size.height)];
    container.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2+100);
    container.backgroundColor=[UIColor redColor];
    
    [self.view addSubview:container];
    
    
    
    iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, container.frame.size.width           , container.frame.size.height)];
    [container addSubview:iconImageView];
    
    
    
    jobNameLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, slotClass.frame.size.width,100 )];
    jobNameLb.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2+250);
    jobNameLb.backgroundColor=[UIColor redColor];
    [jobNameLb setTextAlignment:NSTextAlignmentCenter];

    [self.view addSubview:jobNameLb];
    
    
    
    
    
    
    
    
}


-(void)start{
    NSInteger iconArrayCount = _slotIcon.count;
    NSInteger slotIndex = arc4random()%iconArrayCount;
    iconImageView.image = [_slotIcon objectAtIndex:slotIndex];
    _jobName=[_iconText objectAtIndex:slotIndex];
    slotClass.slotResult = [NSArray arrayWithObject:[NSNumber numberWithInteger:slotIndex]];
    jobNameLb.text =_jobName;
    
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)slotMachineWillStart:(SlotMachineClass *)slotClass{
    _startBtn.enabled=NO;
}
-(void)slotMachineDidEnd:(SlotMachineClass *)slotClass{
    _startBtn.enabled=YES;
}
-(NSArray*)iconsForMachine:(SlotMachineClass *)slotClass{
    return _slotIcon;
}
-(NSInteger)numberOfslotsInMachine:(SlotMachineClass *)slotClass{
    return 4;
}



@end
