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

//Eric
#import "NetworkController.h"
#import "Match.h"
#import "Player.h"

#define INPUT_BAR_HEIGHT 60

@interface ViewController () <NetworkControllerDelegate, UITableViewDelegate, UITableViewDataSource,NSStreamDelegate, UITextFieldDelegate> {
    
    UIView *inputBar;
    CGRect originframeChatBox;
    struct CGColor *oringincolorChatBox;
    
    NSMutableArray *playerDragImageViewArray;
    
    NSMutableArray *chatData;
}

@property (weak, nonatomic) IBOutlet UITableView *chatBoxTableView;
@property (weak, nonatomic) IBOutlet UITableView *playerListTableView;
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *extraBtn;
@property (weak, nonatomic) IBOutlet UIView *thePlayerView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImg;

//Eric
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    ////////chatBoxTableView
    chatData = [NSMutableArray new];
    
     self.chatBoxTableView.backgroundColor=[UIColor colorWithWhite:1 alpha:0.5];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
   
    inputBar = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY([UIScreen mainScreen].bounds)-INPUT_BAR_HEIGHT, CGRectGetWidth([UIScreen mainScreen].bounds),INPUT_BAR_HEIGHT)];
    inputBar.backgroundColor = [UIColor grayColor];
    
    [inputBar addSubview:self.chatTextField];
    [inputBar addSubview:self.sendBtn];
    [inputBar addSubview:self.extraBtn];
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

-(void)keyboardWillChangeFrame:(NSNotification*)notify{

    CGRect keyboardRect = [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat durationTime = [notify.userInfo[UIKeyboardAnimationDurationUserInfoKey]floatValue];
    CGFloat transFromY = keyboardRect.origin.y - self.view.frame.size.height;

    [UIView beginAnimations:@"animation2" context:nil];
    [UIView animateWithDuration:durationTime animations:^{
        
        inputBar.transform=CGAffineTransformMakeTranslation(0, transFromY);
        }];
    
    [UIView animateWithDuration:durationTime animations:^{
        
          self.chatBoxTableView.transform =CGAffineTransformMakeTranslation(0, transFromY);
        }];
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
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.playerListTableView cache:YES];
    [self.playerListTableView setTranslatesAutoresizingMaskIntoConstraints:YES];
        NSLog(@"self.playerListTableViewX=%f",self.playerListTableView.frame.origin.x);
    NSLog(@"self.playerListTableViewY=%f",self.playerListTableView.frame.origin.y);
    CGRect frame = self.playerListTableView.frame;
    
    if(frame.origin.y<0) {

        frame.origin.y =20;
        
    }else {
        
        frame.origin.y -=frame.size.height+20;
    }
    
    NSLog(@"frame=%f",frame.origin.y);
    self.playerListTableView.frame =frame;
    
    [UIView commitAnimations];
}

- (IBAction)sendButtonPressed:(id)sender {
    
    NSString *chat = self.chatTextField.text;
    
    if (chat.length > 0) {
        //for self
        for (Player *player in self.match.players) {
            
            if ([player.playerId isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                
                NSString *chatString = [NSString stringWithFormat:@"%@: %@",player.alias ,chat];
                [chatData addObject:chatString];
                [self.chatBoxTableView reloadData];
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
                [self.chatBoxTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
            }
        }
        //for other players
        [[NetworkController sharedInstance] sendChat:chat withChatType:ChatToAll];
    }
    //隱藏鍵盤
    [self.view endEditing:TRUE];
    self.chatTextField.text = nil;
}

//若點擊畫面
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:TRUE];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn Called");
    
    [self sendButtonPressed:nil];
    
    return false;
}

#pragma mark - cirleThePlayerImage

-(void)initImageView{
    
    dragImageView *tempDragImageView;
    playerDragImageViewArray = [NSMutableArray new];
    
    for (Player *player in self.match.players) {
        
        tempDragImageView = [[dragImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        tempDragImageView.image = player.playerImage;
        
        [playerDragImageViewArray addObject:tempDragImageView];
    }
}

-(void)transImage:(UIImage*)image{
    
    UIImageView *testView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 400, 400)];
    testView.image=image;
    [self.view addSubview:testView];
    
}

-(void)fromCircleView{
    
    circleView *circle =[[circleView alloc]initWithFrame:CGRectMake(0, 0, self.thePlayerView.frame.size.width, self.thePlayerView.frame.size.height)];
    circle.ImgArray  = playerDragImageViewArray;
    [self.thePlayerView addSubview:circle];
    [circle loadView];
}

#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    playerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
    
    if(cell == nil){
        
        cell = [[playerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"customCell"];
    }
    
    if (tableView == self.playerListTableView){
        
        Player *p = [self.match.players objectAtIndex:indexPath.row];
        
        cell.playerPhoto.image = p.playerImage;
        cell.playerName.text = [NSString stringWithFormat:@"%ld: %@",indexPath.row+1, p.alias];
        cell.vote.text = 0;
        
    }else if (tableView == self.chatBoxTableView) {
        
        cell.textLabel.text =[chatData objectAtIndex:indexPath.row];

    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == self.playerListTableView){
        
        return self.match.players.count;
        
    }else{
        
        return chatData.count;
    }
}

//Eric
#pragma mark - NetworkControllerDelegate

- (void)networkStateChanged:(NetworkState)networkState {
    
    switch(networkState) {
            
        case NetworkStateNotAvailable:
            
            self.debugLabel.text = @"Not Available";
            break;
            
        case NetworkStatePendingAuthentication:
            
            self.debugLabel.text = @"Pending Authentication";
            break;
            
        case NetworkStateAuthenticated:
            
            self.debugLabel.text = @"Authenticated";
            break;
            
        case NetworkStateConnectingToServer:
            
            self.debugLabel.text = @"Connecting to Server";
            break;
            
        case NetworkStateConnected:
            
            self.debugLabel.text = @"Connected";
            break;
            
        case NetworkStatePendingMatchStatus:
            
            self.debugLabel.text = @"Pending Match Status";
            break;
            
        case NetworkStateReceivedMatchStatus:
            
            self.debugLabel.text = @"Received Match Status,\nReady to Look for a Match";
            [self dismissViewControllerAnimated:self completion:nil];
            break;
            
        case NetworkStatePendingMatch:
            
            self.debugLabel.text = @"Pending Match";
            break;
            
        case NetworkStatePendingMatchStart:
            
            self.debugLabel.text = @"Pending Start";
            break;
            
        case NetworkStateMatchActive:
            
            self.debugLabel.text = @"Match Active";
            break;
    }
}

- (void)matchStarted:(Match *)match {
    
}
- (IBAction)pressentBtnPressed:(id)sender {
    
    
    

- (void)updateChat:(NSString *)chat withPlayerId:(NSString *)playerId {

    for (Player *player in self.match.players) {

        if ([player.playerId isEqualToString:playerId]) {
            
            NSString *chatString = [NSString stringWithFormat:@"%@: %@",player.alias ,chat];
            [chatData addObject:chatString];
            [self.chatBoxTableView reloadData];
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
            [self.chatBoxTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
        }
    }
}

@end
