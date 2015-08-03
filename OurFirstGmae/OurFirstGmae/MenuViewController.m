//
//  MenuViewController.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "MenuViewController.h"
#import "NetworkController.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UILabel *debugLabel;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [NetworkController sharedInstance].delegate = self;
    [self networkStateChanged:[NetworkController sharedInstance].networkState];
}

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
            
            _debugLabel.text = @"Received Match Status";
            break;
            
        case NetworkStatePendingMatch:
            
            _debugLabel.text = @"Pending Match";
            break;
            
        case NetworkStateMatchActive:
            
            _debugLabel.text = @"Match Active";
            break;
            
        case NetworkStatePendingMatchStart:
            
            _debugLabel.text = @"Pending Start";
            break;
    }
}

- (void)setNotInMatch {
    
    [[NetworkController sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
