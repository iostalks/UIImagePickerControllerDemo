//
//  FYJImagePickerViewController.m
//  ImagePicker
//
//  Created by Jone on 15/7/15.
//  Copyright (c) 2015年 HangZhou DeLan Technology Co. All rights reserved.
//

#import "FYJImagePickerViewController.h"

const CGFloat ButtonWidth = 60.0;
const CGFloat FYJImagePickerScale = 1.25;

@interface FYJImagePickerViewController ()

@property (nonatomic, strong) UIImageView *referenceImageView;
@property (nonatomic, assign) CGRect resetFrame; // 复位frame

@end

@implementation FYJImagePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.showsCameraControls = NO;
    self.cameraViewTransform = CGAffineTransformMakeScale(FYJImagePickerScale, FYJImagePickerScale);
    CGRect overlayFrame = [[UIScreen mainScreen] bounds];
//    CGRect overlayFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*FYJImagePickerScale*0.675);
//    self.cameraOverlayView.backgroundColor = [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:0.3];
    self.cameraOverlayView.frame = overlayFrame;
    
    // overly image
    UIImageView *refrenceImageView = [[UIImageView alloc] init];
    UIImage *overlyImage = [UIImage imageNamed:@"plant_test"];
    refrenceImageView.image = overlyImage;
    refrenceImageView.frame = CGRectMake(0, 0, overlyImage.size.width, overlyImage.size.height);
    refrenceImageView.center = self.cameraOverlayView.center;
    refrenceImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self.cameraOverlayView addSubview:refrenceImageView];
    _referenceImageView = refrenceImageView;
    _resetFrame = refrenceImageView.frame;
    
    // pinch gesture
    UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureResponse:)];
    pinGesture.scale = 1.0f;
    [self.cameraOverlayView addGestureRecognizer:pinGesture];
    
    // pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureResponse:)];
    [self.cameraOverlayView addGestureRecognizer:pan];
    
    [self prepareSubView]; // Intialize Button

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Intialize Button
- (void)prepareSubView
{
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, mainBounds.size.height*FYJImagePickerScale*0.675, mainBounds.size.width, mainBounds.size.height*(1-FYJImagePickerScale*0.675))];
    bottomView.backgroundColor = [UIColor blackColor];
    [self.cameraOverlayView addSubview:bottomView];
    
    // take photo button
    UIButton *captureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [captureBtn setTitle:@"" forState:UIControlStateNormal];
    [captureBtn setImage:[UIImage imageNamed:@"fyj_capture_button"] forState:UIControlStateNormal];
    captureBtn.frame = CGRectMake(self.cameraOverlayView.frame.size.width/2-ButtonWidth/2, bottomView.frame.size.height - (ButtonWidth + 10), ButtonWidth, ButtonWidth);
    [captureBtn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:captureBtn];
    
    // calcel button
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    CGRect frame = captureBtn.frame;
    frame.origin.x = 0;
    cancleBtn.frame = frame;
    [cancleBtn addTarget:self action:@selector(cancelButtonOnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cancleBtn];
    
    // reset button
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetBtn setTitle:@"复位" forState:UIControlStateNormal];
    CGRect reSetBtnframe = captureBtn.frame;
    reSetBtnframe.origin.x = self.cameraOverlayView.frame.size.width - reSetBtnframe.size.width;
    resetBtn.frame = reSetBtnframe;
    [resetBtn addTarget:self action:@selector(resetButtonOnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:resetBtn];
    
}

#pragma mark - Button Action

- (void)takePhoto
{
    if ([_imageDelegate respondsToSelector:@selector(overlyImageFrame:)]) {
        // 位置和大小调整
        CGRect imageFrame = _referenceImageView.frame;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        imageFrame.origin.y = imageFrame.origin.y + bounds.size.height * (FYJImagePickerScale - 1) / 2;
        imageFrame.origin.x = imageFrame.origin.x + bounds.size.width * (FYJImagePickerScale - 1) / 2;
        [_imageDelegate overlyImageFrame:imageFrame];
    }
    [self takePicture];
}

- (void)cancelButtonOnTouched:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)resetButtonOnTouched:(UIButton *)sender
{
    _referenceImageView.frame = _resetFrame;
}

#pragma mark - Gesture response

- (void)pinchGestureResponse:(UIPinchGestureRecognizer *)pinchGesture
{    
    CGFloat localScale = pinchGesture.scale*0.06 + 0.93;
    if (pinchGesture.state == UIGestureRecognizerStateEnded) {
        if (localScale < 0.95 || localScale > 1.05) {
            _referenceImageView.transform = CGAffineTransformIdentity;
            _referenceImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
    }
    _referenceImageView.transform = CGAffineTransformScale(_referenceImageView.transform, localScale, localScale);
}

- (void)panGestureResponse:(UIPanGestureRecognizer *)panGestureResponse
{
    CGPoint panPoint = [panGestureResponse locationInView:self.view];
    CGRect frame = _referenceImageView.frame;
    frame.origin.y = panPoint.y-_referenceImageView.frame.size.height/2;
    frame.origin.x = panPoint.x;
    _referenceImageView.frame = frame;

}


@end
