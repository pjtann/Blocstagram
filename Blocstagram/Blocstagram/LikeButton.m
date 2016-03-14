//
//  LikeButton.m
//  Blocstagram
//
//  Created by PT on 3/11/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "LikeButton.h"
#import "CircleSpinnerView.h"

// define the image names for the different states
#define kLikedStateImage @"heart-full"
#define kUnlikedStateImage @"heart-empty"

@interface LikeButton ()

// property for storing the spinner view
@property (nonatomic, strong) CircleSpinnerView *spinnerView;


@end


@implementation LikeButton

-(instancetype) init{
    self = [super init];
 
    // create the spinner view and set up the button
    if (self) {
        self.spinnerView = [[CircleSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self addSubview:self.spinnerView];
        
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
        self.likeButtonState = LikeStateNotLiked;
        
    
    }
    return self;
    
}

// the spinner view's frame needs to be updated whenver the button's frame changes
-(void) layoutSubviews{
    [super layoutSubviews];
    self.spinnerView.frame = self.imageView.frame;
    
}


// update the button's appearance based on the set state
- (void) setLikeButtonState:(LikeState)likeState {
    _likeButtonState = likeState;
    
    NSString *imageName;
    
    switch (_likeButtonState) {
        case LikeStateLiked:
        case LikeStateUnliking:
            imageName = kLikedStateImage;
            break;
            
        case LikeStateNotLiked:
        case LikeStateLiking:
            imageName = kUnlikedStateImage;
    }
    
    switch (_likeButtonState) {
        case LikeStateLiking:
        case LikeStateUnliking:
            self.spinnerView.hidden = NO;
            self.userInteractionEnabled = NO;
            break;
            
        case LikeStateLiked:
        case LikeStateNotLiked:
            self.spinnerView.hidden = YES;
            self.userInteractionEnabled = YES;
    }
    
    
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}







/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
