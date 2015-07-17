//
//  ViewController.m
//  ImagePicker
//
//  Created by Jone on 15/7/14.
//  Copyright (c) 2015年 HangZhou DeLan Technology Co. All rights reserved.
//

#import "ViewController.h"
#import "FYJImagePickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,FYJImagePickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) CGRect overlayImageFrame;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (IBAction)takePhoto:(id)sender
{
    // camera availbale
    if ([FYJImagePickerViewController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
       
        FYJImagePickerViewController *uiipc = [[FYJImagePickerViewController alloc] init];
        uiipc.delegate = self;
        uiipc.imageDelegate = self;
        uiipc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        uiipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        uiipc.videoQuality = UIImagePickerControllerQualityTypeMedium;

        [self presentViewController:uiipc animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            self.imageView.image = nil;
        }];
        
        
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法获取摄像头" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }
                     
}

#pragma mark - UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    self.imageView.image = image;

    UIImage *getImage = [UIImage imageNamed:@"plant_test"];
    UIImage *combinationImage = [self addImage:getImage toImage:image]; // 组合照片
    self.imageView.image = combinationImage;
//    [self savePictureToLibratyWithImage:combinationImage];  // 写入相册
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)overlyImageFrame:(CGRect)frame
{
    _overlayImageFrame = frame;
}

#pragma mark - Private Method

- (void)savePictureToLibratyWithImage:(UIImage *)image
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:[image CGImage]
                              orientation:(ALAssetOrientation)[image imageOrientation]
                          completionBlock:^(NSURL *assetURL, NSError *error){
        self.imageView.image = image;
    }];
}

- (UIImage *)addImage:(UIImage *)topImage toImage:(UIImage *)bottomImage
{
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGFloat sizeScale = _overlayImageFrame.size.width / ((screenFrame.size.width) * FYJImagePickerScale); // size比例
    // origin比例
    CGFloat originYScale = (screenFrame.size.width*FYJImagePickerScale - (_overlayImageFrame.origin.x + _overlayImageFrame.size.width)) / (screenFrame.size.width*FYJImagePickerScale);
    CGFloat originXScale = _overlayImageFrame.origin.y / (screenFrame.size.height);
    
    UIGraphicsBeginImageContext(CGSizeMake(bottomImage.size.width, bottomImage.size.height));
    [bottomImage drawInRect:CGRectMake(0, 0, bottomImage.size.width, bottomImage.size.height)];
    [topImage drawInRect:CGRectMake(bottomImage.size.width*originXScale, bottomImage.size.height*originYScale, (bottomImage.size.width) * sizeScale, (bottomImage.size.height) * sizeScale)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

@end
