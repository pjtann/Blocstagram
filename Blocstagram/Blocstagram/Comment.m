//
//  Comment.m
//  Blocstagram
//
//  Created by PT on 1/14/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "Comment.h"
#import "User.h"

@implementation Comment

// When the from dictionary is reached in this method, Comment will extract it and pass it to User for parsing = I don't understand how it does this???
// This is an example of the design principles encapsulation and separation of concerns.

- (instancetype) initWithDictionary:(NSDictionary *)commentDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = commentDictionary[@"id"];
        self.text = commentDictionary[@"text"];
        self.from = [[User alloc] initWithDictionary:commentDictionary[@"from"]];
    }
    
    return self;
}


@end
