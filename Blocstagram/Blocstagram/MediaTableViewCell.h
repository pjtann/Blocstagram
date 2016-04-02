//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by PT on 1/15/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media, MediaTableViewCell, ComposeCommentView;


// define the protocol
@protocol MediaTableViewCellDelegate <NSObject>

// define method that will inform the cell's controller when teh user taps an image
-(void) cell:(MediaTableViewCell *) cell didTapImageView:(UIImageView *) imageView;

//method to trigger when a user does a long-press on an image
-(void) cell:(MediaTableViewCell *) cell didLongPressImageView:(UIImageView *) imageView;

//method to indicate that the like button was pressed
-(void) cellDidPressLikeButton:(MediaTableViewCell *) cell;


- (void) cellWillStartComposingComment:(MediaTableViewCell *)cell;
- (void) cell:(MediaTableViewCell *)cell didComposeComment:(NSString *)comment;




@end



@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;
// property for the tap image protocol and method
@property (nonatomic, weak) id <MediaTableViewCellDelegate> delegate;

@property (nonatomic, strong, readonly) ComposeCommentView *commentView;

@property (nonatomic, strong) UITraitCollection *overrideTraitCollection;


// method to calculate teh precise height for each cell since no two cells are identical
+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width traitCollection:(UITraitCollection *) traitCollection;




// Add a public, readonly property for the comment view and a similar stopComposingComment method:
- (void) stopComposingComment;



// We need to set the media item for the cell. When we declare a property like @property (nonatomic, strong) Media *mediaItem;, the compiler generates two hidden methods for us, a getter and a setter. the two method declarations below accomplish this:

// Get the media item (the "getter")
- (Media *)mediaItem;

// Set a new media item (the "setter")
- (void)setMediaItem:(Media *)mediaItem;




@end
