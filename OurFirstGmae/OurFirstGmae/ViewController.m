//
//  ViewController.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/17.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "ViewController.h"
#import "playerCell.h"
#import "circleView.h"
#import "playerInfoViewController.h"
#import "cropView.h"
//#import "playerInfoViewController.h"

//Eric
#import "NetworkController.h"
#import "Match.h"
#import "Player.h"

#define INPUT_BAR_HEIGHT 60

@interface ViewController () <NetworkControllerDelegate> {
    
    UIView *inputBar;
    CGRect originframeChatBox;
    struct CGColor *oringincolorChatBox;
    
    NSMutableArray *playerDragImageViewArray;
}

@property (weak, nonatomic) IBOutlet UITableView *chatBoxTableView;
@property (weak, nonatomic) IBOutlet UITableView *playerListTableView;
@property (weak, nonatomic) IBOutlet UITextField *theTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *extraBtn;
@property (weak, nonatomic) IBOutlet UIImageView *theImage;
@property (weak, nonatomic) IBOutlet UIButton *theName;
@property (weak, nonatomic) IBOutlet UILabel *thevote;
@property (weak, nonatomic) IBOutlet UIView *thePlayerView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImg;
@property (weak, nonatomic) IBOutlet UIView *text;

//Eric
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    ////////chatBoxTableView
    messageData = [NSMutableArray new];
    
     _chatBoxTableView.backgroundColor=[UIColor colorWithWhite:1 alpha:0.5];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
   
    inputBar = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY([UIScreen mainScreen].bounds)-INPUT_BAR_HEIGHT, CGRectGetWidth([UIScreen mainScreen].bounds),INPUT_BAR_HEIGHT)];
    inputBar.backgroundColor = [UIColor grayColor];
    
    [inputBar addSubview:_theTextField];
    [inputBar addSubview:_sendBtn];
    [inputBar addSubview:_extraBtn];
    inputBar.backgroundColor=[UIColor grayColor];
    [self.view addSubview:inputBar];
    
    //////
    
    self.playerListTableView.delegate=self;
    self.playerListTableView.dataSource=self;
    self.backgroundImg.image=[UIImage imageNamed:@"play7.jpg"];

    ///////cicle
    [self initImageView];
    [self fromCircleView];

//    playerInfoViewController *playerController = [playerInfoViewController new];
//    playerController.delegate=self;
    
    //Eric
    [NetworkController sharedInstance].delegate = self;
    [self networkStateChanged:[NetworkController sharedInstance].networkState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark cirleThePlayerImage

-(void)initImageView{

    dragImageView *tempDragImageView;
    playerDragImageViewArray = [NSMutableArray new];
    
    for (Player *player in self.match.players) {
        
        tempDragImageView = [[dragImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        //TODO:change image according to player
        tempDragImageView.image = [UIImage imageNamed:@"play7.jpg"];
        
        [playerDragImageViewArray addObject:tempDragImageView];
    }
}

-(void)transImage:(UIImage*)image{
   
    UIImageView *testView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 400, 400)];
    testView.image=image;
    [self.view addSubview:testView];

}

-(void)fromCircleView{
    
    circleView *circle =[[circleView alloc]initWithFrame:CGRectMake(0, 0, _thePlayerView.frame.size.width, _thePlayerView.frame.size.height)];
    circle.ImgArray  = playerDragImageViewArray;
    [_thePlayerView addSubview:circle];
    [circle loadView];
}

#pragma mark ChatOnStream

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
    // NSStreamEventOpenCompleted = 1UL << 0,//輸入輸出流打開完成
    // NSStreamEventHasBytesAvailable = 1UL << 1,//有字節可讀
    // NSStreamEventHasSpaceAvailable = 1UL << 2,//可以發放字節
    // NSStreamEventErrorOccurred = 1UL << 3,//連接出現錯誤
    // NSStreamEventEndEncountered = 1UL << 4//連接結束
    
    switch (eventCode) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            
            if (aStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (output != nil) {
                            NSLog(@"server said: %@", output);
                            [self getMessageFromOutput:output];
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            break;
            
        case NSStreamEventNone:
            NSLog(@"NSStreamEventNone");
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"NSStreamEventHasSpaceAvailable");
            break;
            
        default:
            NSLog(@"Unknown event");
    }
}

-(void)getMessageFromOutput:(NSString*)mesage{
    
    [messageData addObject:mesage];
    [_chatBoxTableView reloadData];
    
    NSIndexPath *topIndexPath =
    [NSIndexPath indexPathForRow:messageData.count-1
                       inSection:0];
    [self.chatBoxTableView scrollToRowAtIndexPath:topIndexPath
                      atScrollPosition:UITableViewScrollPositionMiddle
                              animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    playerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
    
    if(cell == nil){
        
        cell = [[playerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"customCell"];
    }
    
    if (tableView == self.playerListTableView){

        Player *p = [_match.players objectAtIndex:indexPath.row];
        
        cell.playerPhoto.image = p.playerImage;
        cell.playerName.text = [NSString stringWithFormat:@"%ld: %@",indexPath.row+1, p.alias];
        cell.vote.text = 0;

    }else{

        NSString *cellMessage =[messageData objectAtIndex:indexPath.row];
        cell.textLabel.text =cellMessage;
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == self.playerListTableView){
        
        return _match.players.count;
        
    }else{

        return messageData.count;
    }
}

-(void)keyboardWillChangeFrame:(NSNotification*)notify{

    CGRect keyboardRect = [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat durationTime = [notify.userInfo[UIKeyboardAnimationDurationUserInfoKey]floatValue];
    CGFloat transFromY = keyboardRect.origin.y - self.view.frame.size.height;

    [UIView beginAnimations:@"animation2" context:nil];
    [UIView animateWithDuration:durationTime animations:^{
        
        inputBar.transform=CGAffineTransformMakeTranslation(0, transFromY);
        }];
    
    [UIView animateWithDuration:durationTime animations:^{
        
          _chatBoxTableView.transform =CGAffineTransformMakeTranslation(0, transFromY);
        }];
}

- (IBAction)sentBtnPressed:(id)sender {
    
    NSString *response = [NSString stringWithFormat:@"msg:%@",_theTextField.text];
    NSData *datas = [[NSData alloc]initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[datas bytes] maxLength:[datas length]];
    _theTextField.text=@"";
    
    if (self.resignFirstResponderWhenSend) {
        
        [self resignFirstResponder];
    }
}

- (IBAction)extraBtnPressed:(id)sender {
    
}

- (void)performTransition:(UIViewAnimationOptions)options{
    
    static int count = 0;
    NSArray *animationImages = @[[UIImage imageNamed:@"play6.jpg"], [UIImage imageNamed:@"play7.jpg"]];
    UIImage *image = [animationImages objectAtIndex:(count % [animationImages count])];
    
    [UIView transitionWithView:self.backgroundImg
                      duration:1.0f // animation duration
                       options:options
                    animations:^{
                        self.backgroundImg.image = image; // change to other image
                    } completion:^(BOOL finished) {
                        [self backgroundImg]; // once finished, repeat again
                        count++; // this is to keep the reference of which image should be loaded next
                    }];
}

- (IBAction)finalSelectBtnPressed:(id)sender {
    
    [self performTransition:UIViewAnimationOptionTransitionCrossDissolve];
}

- (IBAction)controlListBtnPressed:(id)sender {
    
    [UIView beginAnimations:@"animation1" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:_playerListTableView cache:YES];
    [self.playerListTableView setTranslatesAutoresizingMaskIntoConstraints:YES];
        NSLog(@"_playerListTableViewX=%f",_playerListTableView.frame.origin.x);
    NSLog(@"_playerListTableViewY=%f",_playerListTableView.frame.origin.y);
    CGRect frame = _playerListTableView.frame;
    
    if(frame.origin.y<0) {

        frame.origin.y =20;
        
    }else {
        
        frame.origin.y -=frame.size.height+20;
    }
    
    NSLog(@"frame=%f",frame.origin.y);
    _playerListTableView.frame =frame;
    
    [UIView commitAnimations];
}

-(BOOL)resignFirstResponderWhenSend{
    
    [self.theTextField resignFirstResponder];
    return [super resignFirstResponder];
}

//Eric
#pragma mark - NetworkControllerDelegate

- (void)networkStateChanged:(NetworkState)networkState {
    
    switch(networkState) {
            
        case NetworkStateNotAvailable:
            
            _debugLabel.text = @"Not Available";
            break;
            
        case NetworkStatePendingAuthentication:
            
            _debugLabel.text = @"Pending Authentication";
            break;
            
        case NetworkStateAuthenticated:
            
            _debugLabel.text = @"Authenticated";
            break;
            
        case NetworkStateConnectingToServer:
            
            _debugLabel.text = @"Connecting to Server";
            break;
            
        case NetworkStateConnected:
            
            _debugLabel.text = @"Connected";
            break;
            
        case NetworkStatePendingMatchStatus:
            
            _debugLabel.text = @"Pending Match Status";
            break;
            
        case NetworkStateReceivedMatchStatus:
            
            _debugLabel.text = @"Received Match Status,\nReady to Look for a Match";
            [self dismissViewControllerAnimated:self completion:nil];
            break;
            
        case NetworkStatePendingMatch:
            
            _debugLabel.text = @"Pending Match";
            break;
            
        case NetworkStatePendingMatchStart:
            
            _debugLabel.text = @"Pending Start";
            break;
            
        case NetworkStateMatchActive:
            
            _debugLabel.text = @"Match Active";
            break;
    }
}

- (void)matchStarted:(Match *)match {
    
}
- (IBAction)pressentBtnPressed:(id)sender {
    
    
    
}

@end
