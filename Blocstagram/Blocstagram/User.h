//
//  User.h
//  Blocstagram
//
//  Created by PT on 1/14/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSURL *profilePictureURL;
@property (nonatomic, strong) UIImage *profilePicture;

-(instancetype) initWithDictionary:(NSDictionary *) userDictionary;


@end
