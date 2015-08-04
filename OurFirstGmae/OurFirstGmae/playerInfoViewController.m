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
#import "ViewController.h"

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
  
    _crop.layer.borderWidth=1.0;
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
    [_crop step];
    
    
    
    
   
     [self presentViewController:ImagePicker animated:YES completion:NULL];
    
    
}





//
//- (IBAction)nextButton:(id)sender {
//    
////    UIGraphicsBeginImageContext(_crop.bounds.size);
////    [_crop.layer renderInContext:UIGraphicsGetCurrentContext()];
////    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
////    UIGraphicsEndImageContext();
////
////    [self.delegate transImage:myImage];
//    
//    
//    
//    
//   
////    UIImageView *testView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 400, 400)];
////    testView.image=myImage;
////    [self.view addSubview:testView];
////    [self.delegate transImage:myImage];
////   
////    
//////    
////    [self performSegueWithIdentifier:@"goMainView" sender:nil];
//    
//    
//    
//    
//}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"goMain"])
    {
        
        UIGraphicsBeginImageContext(_crop.cover.bounds.size);
        [_crop.cover.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        ViewController *vc = [segue destinationViewController];
        vc.transImage =myImage;
        
        
    }
    
    
    
}


@end
