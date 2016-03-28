//
//  ComposeCommentView.m
//  Blocstagram
//
//  Created by PT on 3/26/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "ComposeCommentView.h"

//This view contains a text view and a button, so let's add properties to store those, and declare that it conforms to the UITextViewDelegate protocol:

@interface ComposeCommentView () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *button;

@end


@implementation ComposeCommentView


//In the initializer, create and configure these objects and add them to the view hierarchy. A new method, commentAttributedString, will generate an attributed string for the button text:
//self.button is a subview of self.textView, not self. This will be helpful when we want to wrap long comment text around the button.
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textView = [UITextView new];
        self.textView.delegate = self;
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setAttributedTitle:[self commentAttributedString] forState:UIControlStateNormal];
        [self.button addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.textView];
        [self.textView addSubview:self.button];
    }
    return self;
}

- (NSAttributedString *) commentAttributedString {
    NSString *baseString = NSLocalizedString(@"COMMENT", @"comment button text");
    NSRange range = [baseString rangeOfString:baseString];
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:baseString];
    
    [commentString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10] range:range];
    [commentString addAttribute:NSKernAttributeName value:@1.3 range:range];
    [commentString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1] range:range];
    
    return commentString;
}







//To lay out the views, we must account for two different states:While the user is scrolling, the comment button is gray, and on the left. Once the user starts editing, the button slides to the right and fades to purple. We'll define this programmatically in layoutSubviews:
// The current value of isWritingComment determines each view's background color and frame. After the conditionals, we set the text view's text container's exclusion paths to include a UIBezierPath made from a CGRect that's a bit larger than the comment button. The text view won't draw text that intersects with this path, causing it to wrap:


- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.textView.frame = self.bounds;
    
    if (self.isWritingComment) {
        self.textView.backgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; /*#eeeeee*/
        self.button.backgroundColor = [UIColor colorWithRed:0.345 green:0.318 blue:0.424 alpha:1]; /*#58516c*/
        
        CGFloat buttonX = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.button.frame) - 20;
        self.button.frame = CGRectMake(buttonX, 10, 80, 20);
    } else {
        self.textView.backgroundColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1]; /*#e5e5e5*/
        self.button.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1]; /*#999999*/
        
        self.button.frame = CGRectMake(10, 10, 80, 20);
    }
    
    CGSize buttonSize = self.button.frame.size;
    buttonSize.height += 20;
    buttonSize.width += 20;
    CGFloat blockX = CGRectGetWidth(self.textView.bounds) - buttonSize.width;
    CGRect areaToBlockText = CGRectMake(blockX, 0, buttonSize.width, buttonSize.height);
    UIBezierPath *buttonPath = [UIBezierPath bezierPathWithRect:areaToBlockText];
    
    self.textView.textContainer.exclusionPaths = @[buttonPath];
}


//Dismiss the keyboard when stopComposingComment is called:
- (void) stopComposingComment {
    [self.textView resignFirstResponder];
}


//If isWritingComment changes, update the view appropriately: Here we're providing both an animated and immediate way to update the view. Setting isWritingComment directly calls setIsWritingComment:animated:, passing NO for the animated variable. Within setIsWritingComment:animated:, we store the new setting, and call layoutSubviews to update the view positioning; either with or without an animation block, as appropriate.
#pragma mark - Setters & Getters

- (void) setIsWritingComment:(BOOL)isWritingComment {
    [self setIsWritingComment:isWritingComment animated:NO];
}

- (void) setIsWritingComment:(BOOL)isWritingComment animated:(BOOL)animated {
    _isWritingComment = isWritingComment;
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutSubviews];
        }];
    } else {
        [self layoutSubviews];
    }
}

//When text is set, we should update the text view. We should also determine which mode is correct depending on if text is empty: We also reset userInteractionEnabled to YES. We'll set it to NO when uploading a comment to the API.

- (void) setText:(NSString *)text {
    _text = text;
    self.textView.text = text;
    self.textView.userInteractionEnabled = YES;
    self.isWritingComment = text.length > 0;
}


//When the button is tapped, we want to do one of two things: If the user hasn't started writing, bring up the keyboard. If the user is done writing, send the comment to the API.

#pragma mark - Button Target

- (void) commentButtonPressed:(UIButton *) sender {
    if (self.isWritingComment) {
        [self.textView resignFirstResponder];
        self.textView.userInteractionEnabled = NO;
        [self.delegate commentViewDidPressCommentButton:self];
    } else {
        [self setIsWritingComment:YES animated:YES];
        [self.textView becomeFirstResponder];
    }
}

//We'll use the UITextViewDelegate protocol to inform the delegate of user actions, and to update isWritingComment appropriately:These delegate methods allow us to restrict the user in some way, but we're not interested in that. In all cases, we update state, communicate user intent and return YES to allow the user to do what they want.
#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self setIsWritingComment:YES animated:YES];
    [self.delegate commentViewWillStartEditing:self];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    [self.delegate commentView:self textDidChange:newText];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    BOOL hasComment = (textView.text.length > 0);
    [self setIsWritingComment:hasComment animated:YES];
    
    return YES;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
