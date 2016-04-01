//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by PT on 2/29/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaFullScreenViewController : UIViewController

//declare a property to store the media in
@property (nonatomic, strong) Media *media;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

- (void) recalculateZoomScale;


-(instancetype) initWithMedia:(Media *) media;

-(void) centerScrollView;



@end
