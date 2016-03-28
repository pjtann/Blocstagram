//
//  Media.h
//  Blocstagram
//
//  Created by PT on 1/14/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LikeButton.h"


// declare an enumeration for persisting the download state. Declares MediaDownloadState as equivalent to NSInteger with predefined values 0-3
typedef NS_ENUM(NSInteger, MediaDownloadState) {
    MediaDownloadStateNeedsImage = 0,
    MediaDownloadStateDownloadInProgress = 1,
    MediaDownloadStateNonRecoverableError = 2,
    MediaDownloadStateHasImage = 3
};



@class User; // use this class declaration rather than an import in a header file for best practice; you still use the import in the implementation file though

@interface Media : NSObject <NSCoding>

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSArray *comments;

// property to keep the media item's state
@property (nonatomic, assign) LikeState likeState;



// property to keep track of an individual media items download state. Uses "assign" rather than strong or weak in the declaration because it's not an object; it's a simpler type
@property (nonatomic, assign) MediaDownloadState downloadState;

// Let's add a property to Media to store the comment as it's being written:
@property (nonatomic, strong) NSString *temporaryComment;



-(instancetype) initWithDictionary:(NSDictionary *) mediaDictionary;

@end
