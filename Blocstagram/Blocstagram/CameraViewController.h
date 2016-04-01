//
//  CameraViewController.h
//  Blocstagram
//
//  Created by PT on 3/30/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

//Users will use this view controller to take pictures.A delegate property and accompanying protocol will inform the presenting view controller when the camera view controller is done.

#import <UIKit/UIKit.h>

@class CameraViewController;

@protocol CameraViewControllerDelegate <NSObject>

- (void) cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image;

@end


@interface CameraViewController : UIViewController

@property (nonatomic, weak) NSObject <CameraViewControllerDelegate> *delegate;


@end
