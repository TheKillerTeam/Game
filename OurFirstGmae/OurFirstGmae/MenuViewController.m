//
//  MenuViewController.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

//TODO: 1.投票 2.聊天 3.結束遊戲 4.結束後再重新開始 5.斷線重聯 6.邀請好友

#import "MenuViewController.h"
#import "NetworkController.h"
#import "Match.h"
#import "Player.h"
#import "TestGameViewController.h"

#define MIN_PLAYER_COUNTS 2
#define MAX_PLAYER_COUNTS 16

@interface MenuViewController () <NetworkControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, TestGameViewControllerDelegate> {
    
    Match *_match;
    int playerCounts;
}

@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UIPickerView *playerCountsPickerView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    playerCounts = 2;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [NetworkController sharedInstance].delegate = self;
    [self networkStateChanged:[NetworkController sharedInstance].networkState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonPressed:(id)sender {
    
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game center login required" message:@"please login game center to continue" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [rootVC presentViewController:alert animated:YES completion:nil];
    }
    else if (_notInMatch) {
        
        [[NetworkController sharedInstance] findMatchWithMinPlayers:playerCounts maxPlayers:playerCounts viewController:self];
    }
}
#pragma mark - TestGameViewControllerDelegate

- (void)TGVCsetNotInMatch {
    
    _notInMatch = true;
}

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

- (void)setNotInMatch {
    
    _notInMatch = true;
}

- (void)matchStarted:(Match *)match {
    
    _notInMatch = false;
    _match = match;
    
    Player *p1 = [_match.players objectAtIndex:0];
    Player *p2 = [_match.players objectAtIndex:1];
    
    _player1Label.text = p1.alias;
    _player2Label.text = p2.alias;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Eric" bundle:nil];
    TestGameViewController *vc = [sb instantiateViewControllerWithIdentifier:@"TestGameViewController"];
    
    vc.match = match;
    
    vc.delegate = self;

    [self presentViewController:vc animated:true completion:nil];
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return MAX_PLAYER_COUNTS - MIN_PLAYER_COUNTS +1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [NSString stringWithFormat:@"%ld", MIN_PLAYER_COUNTS +row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    playerCounts = (int)(MIN_PLAYER_COUNTS +row);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
