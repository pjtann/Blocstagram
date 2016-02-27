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

#pragma mark - NSCoding


// initWithCoder turns an object that has been read from disk back into an object
-(instancetype) initWithCoder:(NSCoder *)aDecoder{
    
    self = [super init];
    
    if (self) {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.text = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(text))];
        self.from = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(from))];

        
        
    }
    return self;
    
}

// encodeWithCoder - we are given and NSCoder object and we save data into it and then later in the program write it to disk
-(void) encodeWithCoder:(NSCoder *)aCoder{
    
    // convert selectors into strings
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.text forKey:NSStringFromSelector(@selector(text))];
    [aCoder encodeObject:self.from forKey:NSStringFromSelector(@selector(from))];
    
}


@end
