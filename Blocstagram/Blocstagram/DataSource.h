//
//  DataSource.h
//  Blocstagram
//
//  Created by PT on 1/14/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

// adding completion handler for checkpoint f31. We're using typedef to define a block which we can reuse as a parameter in multiple methods.
// Block definitions come in two parts. The first part, void (^NewItemCompletionBlock), specifies the block's return type (void), and gives it a name (NewItemCompletionBlock).The second part ((NSError *error);) lists any parameters passed to the block. These parameters can be of any type or length, just like a method. We've chosen an NSError object as our parameter. This is a typical pattern followed by completion handlers. If the error object comes back as anything other than nil, something has gone wrong during the execution of that method.
// Summary = We've defined a type of completion handler block called NewItemCompletionBlock. When executed, the block may be passed an NSError, and it doesn't return anything. This block type will be used in two cases below: for loading new images, and for loading older images.
typedef void (^NewItemCompletionBlock)(NSError *error);


@interface DataSource : NSObject

+(instancetype) sharedInstance;

@property (nonatomic, strong, readonly) NSArray *mediaItems;

//But how will any class be able to modify the array if it's trapped inside of DataSource? Let's add a method to DataSource which lets other classes delete a media item. Added below method and the class Media declaration above for this purpose.

-(void) deleteMediaItem: (Media *) item;

-(void) requestNewItemsWithCompletionHandler: (NewItemCompletionBlock) completionHandler;

-(void) requestOldItemsWithCompletionHandler: (NewItemCompletionBlock) completionHandler;



@end
