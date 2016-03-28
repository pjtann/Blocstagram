//
//  ComposeCommentView.h
//  Blocstagram
//
//  Created by PT on 3/26/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <UIKit/UIKit.h>

// The compose comment view's delegate protocol will inform its delegate when the user starts editing, updates the text, or presses the comment button. isWritingComment determines whether the user is currently editing a comment. text contains the text of the comment, and will allow an external controller to set text. A controller can call stopComposingComment to end composition and dismiss the keyboard.

@class ComposeCommentView;

@protocol ComposeCommentViewDelegate <NSObject>

- (void) commentViewDidPressCommentButton:(ComposeCommentView *)sender;
- (void) commentView:(ComposeCommentView *)sender textDidChange:(NSString *)text;
- (void) commentViewWillStartEditing:(ComposeCommentView *)sender;

@end

@interface ComposeCommentView : UIView

@property (nonatomic, weak) NSObject <ComposeCommentViewDelegate> *delegate;

@property (nonatomic, assign) BOOL isWritingComment;

@property (nonatomic, strong) NSString *text;

- (void) stopComposingComment;


@end
