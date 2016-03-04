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

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;


-(instancetype) initWithMedia:(Media *) media;

-(void) centerScrollView;



@end
