//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by PT on 1/15/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;


@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;

// method to calculate teh precise height for each cell since no two cells are identical
+(CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;


// We need to set the media item for the cell. When we declare a property like @property (nonatomic, strong) Media *mediaItem;, the compiler generates two hidden methods for us, a getter and a setter. the two method declarations below accomplish this:

// Get the media item (the "getter")
- (Media *)mediaItem;

// Set a new media item (the "setter")
- (void)setMediaItem:(Media *)mediaItem;

@end
