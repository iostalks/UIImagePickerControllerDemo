//
//  FYJImagePickerViewController.h
//  ImagePicker
//
//  Created by Jone on 15/7/15.
//  Copyright (c) 2015年 HangZhou DeLan Technology Co. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat FYJImagePickerScale;

@protocol FYJImagePickerViewControllerDelegate <NSObject>

- (void)overlyImageFrame:(CGRect)frame;

@end

@interface FYJImagePickerViewController : UIImagePickerController

@property (nonatomic, weak) id<FYJImagePickerViewControllerDelegate> imageDelegate;



@end
