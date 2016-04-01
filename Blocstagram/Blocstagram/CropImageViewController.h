//
//  CropImageViewController.h
//  Blocstagram
//
//  Created by PT on 3/31/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "MediaFullScreenViewController.h"

// This view controller's interface indicates: Another controller will pass it a UIImage and set itself as the crop controller's delegate. The user will size and crop the image, and the controller will pass a new, cropped UIImage back to its delegate.

@class CropImageViewController;

@protocol CropImageViewControllerDelegate <NSObject>

- (void) cropControllerFinishedWithImage:(UIImage *)croppedImage;

@end

@interface CropImageViewController : MediaFullScreenViewController

- (instancetype) initWithImage:(UIImage *)sourceImage;

@property (nonatomic, weak) NSObject <CropImageViewControllerDelegate> *delegate;


@end
