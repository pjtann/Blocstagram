//
//  CameraToolbar.h
//  Blocstagram
//
//  Created by PT on 3/30/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <UIKit/UIKit.h>

//The toolbar will have three buttons: customizable left and right buttons, and a center button that looks like a camera.The image names for the icons on the side buttons will be passed to initWithImageNames:.The view will know nothing about the function of these buttons. Instead, the delegate will be informed the when the buttons are pressed.

@class CameraToolbar;

@protocol CameraToolbarDelegate <NSObject>

- (void) leftButtonPressedOnToolbar:(CameraToolbar *)toolbar;
- (void) rightButtonPressedOnToolbar:(CameraToolbar *)toolbar;
- (void) cameraButtonPressedOnToolbar:(CameraToolbar *)toolbar;

@end


@interface CameraToolbar : UIView

- (instancetype) initWithImageNames:(NSArray *)imageNames;

@property (nonatomic, weak) NSObject <CameraToolbarDelegate> *delegate;


@end
