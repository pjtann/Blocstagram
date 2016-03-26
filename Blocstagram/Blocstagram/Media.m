//
//  Media.m
//  Blocstagram
//
//  Created by PT on 1/14/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "Media.h"
#import "User.h"
#import "Comment.h"


@implementation Media

- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary {
    self = [super init];
    
    // Instagram's JSON gives us a few different resolutions of images. We'll just use the standard resolution.
    // Instagram's API provides different results depending on whether an image has a caption or not.
    
    if (self) {
        self.idNumber = mediaDictionary[@"id"];
        self.user = [[User alloc] initWithDictionary:mediaDictionary[@"user"]];
        NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        
    
        
        self.likeCount = [mediaDictionary[@"likes"][@"count"]  integerValue];
                                                   
        NSLog(@"likeCount value...: %ld", self.likeCount);
        
        
        
        
        NSURL *standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURL) {
            self.mediaURL = standardResolutionImageURL;
            
            // set default value for the download state property
            self.downloadState = MediaDownloadStateNeedsImage;
        }else{
            self.downloadState = MediaDownloadStateNonRecoverableError;
            
        }
        
        NSDictionary *captionDictionary = mediaDictionary[@"caption"];
        
        // Caption might be null (if there's no caption)
        //Because mediaDictionary[@"caption"] can return either an NSDictionary or NSNull, we must check to ensure we've got the correct type.NSNull doesn't have keys like NSDictionary does and would cause a crash if we accepted NSNull like a dictionary.
        if ([captionDictionary isKindOfClass:[NSDictionary class]]) {
            self.caption = captionDictionary[@"text"];
        } else {
            self.caption = @"";
        }
        
        NSMutableArray *commentsArray = [NSMutableArray array];
        
        for (NSDictionary *commentDictionary in mediaDictionary[@"comments"][@"data"]) {
            Comment *comment = [[Comment alloc] initWithDictionary:commentDictionary];
            [commentsArray addObject:comment];
        }
        
        self.comments = commentsArray;
        
        // figure out whether the user has already liked the image
        BOOL userHasLiked = [mediaDictionary [@"user_has_liked"] boolValue];
        self.likeState = userHasLiked ? LikeStateLiked : LikeStateNotLiked;
        
        
        
    }
    
    return self;
}

#pragma mark - NSCoding


// initWithCoder turns an object that has been read from disk back into an object
-(instancetype) initWithCoder:(NSCoder *)aDecoder{
    
    self = [super init];
    
    if (self) {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.user = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        self.mediaURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mediaURL))];
        self.image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
        
        // set teh self.downloadState property
        if (self.image) {
            self.downloadState = MediaDownloadStateHasImage;
        }else if(self.mediaURL){
            self.downloadState = MediaDownloadStateNeedsImage;
        }else{
            self.downloadState = MediaDownloadStateNonRecoverableError;
            
        }
        
        
        
        
        
        self.caption = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(caption))];
        self.comments = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(comments))];
        // decode call for the likeState
        self.likeState = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(likeState))];
        
        self.likeCount = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(likeCount))];
        
        
        
        
    }
    return self;
    
}

// encodeWithCoder - we are given and NSCoder object and we save data into it and then later in the program write it to disk
-(void) encodeWithCoder:(NSCoder *)aCoder{
    
    // convert selectors into strings
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeObject:self.mediaURL forKey:NSStringFromSelector(@selector(mediaURL))];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
    [aCoder encodeObject:self.caption forKey:NSStringFromSelector(@selector(caption))];
    [aCoder encodeObject:self.comments forKey:NSStringFromSelector(@selector(comments))];
    // encode call for teh likeState
    [aCoder encodeInteger:self.likeState forKey:NSStringFromSelector(@selector(likeState))];
    
    [aCoder encodeInteger:self.likeCount forKey:NSStringFromSelector(@selector(likeCount))];
    
    
}


@end
