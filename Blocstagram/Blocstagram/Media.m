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
        NSURL *standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURL) {
            self.mediaURL = standardResolutionImageURL;
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
    }
    
    return self;
}


@end
