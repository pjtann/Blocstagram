//
//  LikeButton.h
//  Blocstagram
//
//  Created by PT on 3/11/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <UIKit/UIKit.h>


// define four possible states the like button might be in and create a property for storing this state (below in the interface section)

typedef NS_ENUM(NSInteger, LikeState){
    LikeStateNotLiked = 0,
    LikeStateLiking = 1,
    LikeStateLiked = 2,
    LikeStateUnliking = 3
    
};


@interface LikeButton : UIButton

// define four possible states as above the like button might be in and create a property for storing this state here. The current state of the like button. Setting to LikeButtonNotLiked or LikeButtonLiked will display an empty heart or a heart, respectively. Setting to LikeButtonLiking or LikeButtonUnliking will display an activity indicator and disable button taps until the button is set to LikeButtonNotLiked or LikeButtonLiked.

@property (nonatomic, assign) LikeState likeButtonState;



@end
