//
//  DataSource.h
//  Blocstagram
//
//  Created by PT on 1/14/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

@interface DataSource : NSObject

+(instancetype) sharedInstance;

@property (nonatomic, strong, readonly) NSArray *mediaItems;

//But how will any class be able to modify the array if it's trapped inside of DataSource? Let's add a method to DataSource which lets other classes delete a media item. Added below method and the class Media declaration above for this purpose.

-(void) deleteMediaItem: (Media *) item;

-(void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index;


@end
