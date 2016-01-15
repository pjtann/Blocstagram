//
//  DataSource.h
//  Blocstagram
//
//  Created by PT on 1/14/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSource : NSObject

+(instancetype) sharedInstance;

@property (nonatomic, strong, readonly) NSArray *mediaItems;



@end
