//
//  ViewController.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/17.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dragImageView.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,NSStreamDelegate>
{
    dragImageView *player1;
    dragImageView *player2;
    dragImageView *player3;
    dragImageView *player4;
    dragImageView *player5;
    dragImageView *player6;
    
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSMutableArray *messageData;
//    UIView *inputBar;

}
//@property (weak, nonatomic) IBOutlet UITableView *chatBoxTableView;
//@property (weak, nonatomic) IBOutlet UITableView *playerListTableView;
//@property (weak, nonatomic) IBOutlet UITextField *theTextField;
//@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
//@property (weak, nonatomic) IBOutlet UIButton *extraBtn;
//@property (weak, nonatomic) IBOutlet UIImageView *theImage;
//@property (weak, nonatomic) IBOutlet UIButton *theName;
//@property (weak, nonatomic) IBOutlet UILabel *thevote;
//@property (weak, nonatomic) IBOutlet UIView *thePlayerView;


@end

