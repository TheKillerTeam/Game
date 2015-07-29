//
//  playerInfoViewController.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/28.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "playerInfoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "cropView.h"

@interface playerInfoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImagePickerController *ImagePicker;
    
    
}
@property (weak, nonatomic) IBOutlet UIImageView *playPhoto;

@property (weak, nonatomic) IBOutlet cropView *crop;


@end

@implementation playerInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    _crop.layer.borderWidth=20.0;
    _crop.layer.borderColor=[UIColor redColor].CGColor;
    
    [_crop step];
    

   
  
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)takePhoto:(id)sender {
    ImagePicker = [UIImagePickerController new];
    UIImagePickerControllerSourceType sourceType =UIImagePickerControllerSourceTypeCamera;
    
    
    if([UIImagePickerController isSourceTypeAvailable:sourceType]==false)
    {
        UIAlertController *alert =[UIAlertController alertControllerWithTitle:nil message:@"The deviece dosen't support" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok =[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
        return;
    }

    ImagePicker.showsCameraControls=true;
    ImagePicker.delegate=self;
    ImagePicker.sourceType = sourceType;
  
     [self presentViewController:ImagePicker animated:YES completion:NULL];

    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
//    self.playPhoto.image = chosenImage;
    _crop.image = chosenImage;
    
    
    
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (IBAction)album:(id)sender {
    ImagePicker=[UIImagePickerController new];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    ImagePicker.sourceType = sourceType;
   

    ImagePicker.delegate=self;
    
    
     [self presentViewController:ImagePicker animated:YES completion:NULL];
    
    
}




@end
