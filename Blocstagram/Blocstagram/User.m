//
//  User.m
//  Blocstagram
//
//  Created by PT on 1/14/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "User.h"

@implementation User



- (instancetype) initWithDictionary:(NSDictionary *)userDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = userDictionary[@"id"];
        self.userName = userDictionary[@"username"];
        self.fullName = userDictionary[@"full_name"];
        
        NSString *profileURLString = userDictionary[@"profile_picture"];
        NSURL *profileURL = [NSURL URLWithString:profileURLString];
        
        if (profileURL) {
            self.profilePictureURL = profileURL;
        }
    }
    
    return self;
}

#pragma mark - NSCoding


// initWithCoder turns an object that has been read from disk back into an object
-(instancetype) initWithCoder:(NSCoder *)aDecoder{
    
    self = [super init];
    
    if (self) {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.userName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userName))];
        self.fullName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fullName))];
        self.profilePicture = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(profilePicture))];
        self.profilePictureURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(profilePictureURL))];
        
        
    }
    return self;
    
}

// encodeWithCoder - we are given and NSCoder object and we save data into it and then later in the program write it to disk
-(void) encodeWithCoder:(NSCoder *)aCoder{
    
    // convert selectors into strings
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.userName forKey:NSStringFromSelector(@selector(userName))];
    [aCoder encodeObject:self.fullName forKey:NSStringFromSelector(@selector(fullName))];
    [aCoder encodeObject:self.profilePicture forKey:NSStringFromSelector(@selector(profilePicture))];
    [aCoder encodeObject:self.profilePictureURL forKey:NSStringFromSelector(@selector(profilePictureURL))];
    
}






@end
