//
//  Comment.h
//  Blocstagram
//
//  Created by PT on 1/14/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;


@interface Comment : NSObject <NSCoding>


@property (nonatomic, strong) NSString *idNumber;

@property (nonatomic, strong) User *from;
@property (nonatomic, strong) NSString *text;


-(instancetype) initWithDictionary:(NSDictionary *)commentDictionary;


@end
