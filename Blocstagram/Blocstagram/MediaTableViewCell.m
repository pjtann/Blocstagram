//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by PT on 1/15/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"
#import "LikeButton.h"



@interface MediaTableViewCell () <UIGestureRecognizerDelegate> // declare that this class conforms to the gesture recognizer delegate protocol

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;

@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;

// add a property for the gesture recognizer
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

// property for the long press recognizer
@property (nonatomic, strong) UITapGestureRecognizer *longPressGestureRecognizer;

// property for the Like button
@property (nonatomic, strong) LikeButton *likeButton;







@end


// lightFont will be used for comments and captions; boldFont will be used for usernames. usernameLabelGray will be used as the background color for the username and caption label whereas the commentLabelGray will be a separate background color for the comment section.linkColor will be the text color of every username in order to make it appear tap-able. Finally, an NSParagraphStyle lets us set properties like line spacing, text alignment, indentation, paragraph spacing, etc.

static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;



@implementation MediaTableViewCell

//- (void)awakeFromNib {
//    // Initialization code
//}


//  load is a special method which is called once and only once per class. Any class may implement load. If it does, when the class is first used, the method will be executed before anything else happens:
+(void) load{
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; // #eeeeee
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1]; // #e5e5e5
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1]; // #58506d
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    
    paragraphStyle = mutableParagraphStyle;
    
    
}

// Attributed strings let us perform these rich-text modifications on strings for presentation in iOS.
-(NSAttributedString *) usernameAndCaptionString{
    
    // #1- choose a font size
    CGFloat usernameFontSize = 15;
    
    // #2 - make a string that says "username caption"
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    // #3 - make an attributed string with the "username" bold. We create an NSMutableAttributedString by supplying our base NSString and an NSDictionary with the font and paragraph style we'd like to use. The attributes in the dictionary will apply to the entire attributed string.
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : paragraphStyle}];
    
    // #4 - However, we only want the username to be bold and purple, so in #4 we calculate the NSRange of the username within the base string and apply boldFont and the link color to it. These attributes override the ones which we set previously using the dictionary - but only for the specified NSRange.
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    return mutableUsernameAndCaptionString;
    
    
}

- (NSAttributedString *) commentString {
    
    // commentString wll be a concatenation of every comment found for that particular media item. We use a for loop to iterate over each comment and create its own respective attributed string which we then append to commentString once it's ready.
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    for (Comment *comment in self.mediaItem.comments) {
        // Make a string that says "username comment" followed by a line break
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        
        // Make an attributed string, with the "username" bold
        
        NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
        
        // we calculate the NSRange of the username within the base string and apply font changes
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
        
        [commentString appendAttributedString:oneCommentString];
    }
    
    return commentString;
}

// This method calculates how tall usernameAndCaptionLabel and commentLabel need to be. The boundingRectWithSize:options:context: method will use the text, the attributes, and the maximum width we've supplied to determine how much space our string requires. We do this so that later when we layout our views, we size the labels appropriately. We also add a height of 20 just to pad out the top and bottom which gives the text some breathing room.
//- (CGSize) sizeOfString:(NSAttributedString *)string {
//    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.contentView.bounds) - 40, 0.0);
//    CGRect sizeRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//    sizeRect.size.height += 20;
//    sizeRect = CGRectIntegral(sizeRect);
//    return sizeRect.size;
//}

// In this method we begin by re-using the code from [ImagesTableViewController -tableView:heightForRowAtIndexPath:] that calculates the size of the image. We call sizeOfString: to get the height for the username / caption label and then place it beneath the image. Then, we repeat that logic for the comment string and place it beneath the username / caption label. We also perform a trick which will hide the divider line typically seen between table cells. We don't need it because the next image will be a clear indicator that a new cell has started.

- (void) layoutSubviews {
    [super layoutSubviews];
    
//    CGFloat imageHeight = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
//    self.mediaImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), imageHeight);
//    
//    CGSize sizeOfUsernameAndCaptionLabel = [self sizeOfString:self.usernameAndCaptionLabel.attributedText];
//    self.usernameAndCaptionLabel.frame = CGRectMake(0, CGRectGetMaxY(self.mediaImageView.frame), CGRectGetWidth(self.contentView.bounds), sizeOfUsernameAndCaptionLabel.height);
//    
//    CGSize sizeOfCommentLabel = [self sizeOfString:self.commentLabel.attributedText];
//    self.commentLabel.frame = CGRectMake(0, CGRectGetMaxY(self.usernameAndCaptionLabel.frame), CGRectGetWidth(self.bounds), sizeOfCommentLabel.height);
    
    // Before layout, calculate the intrinsic size of the labels (the size they "want" to be), and add 20 to the height for some vertical padding.
    // In layoutSubviews, we ask the labels for their intrinsic size, add some padding, and set the height constraint constant to that number. (This overwrites the previous 100 value that was set in the initWithStyle method in this file.) The same image calculation logic determines the appropriate height of the image.
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
    
    // Now that we're deleting data, we need to account for the possibility of missing data in our views.
    self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height == 0 ? 0 : usernameLabelSize.height + 20;
    self.commentLabelHeightConstraint.constant = commentLabelSize.height == 0 ? 0 : commentLabelSize.height + 20;

    // This third change is especially important: if self.mediaItem.image.size.width is zero, the calculation will cause a divide-by-zero, which is illegal and will cause a crash.
    if (self.mediaItem.image.size.width > 0 && CGRectGetWidth(self.contentView.bounds) > 0) {
            self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
    }else {
        self.imageHeightConstraint.constant = 0;
        
    }
    
    
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds)/2.0, 0, CGRectGetWidth(self.bounds)/2.0);
}

// When overriding a setter or getter method for a property as in the method below, you must refer to the implicitly generated IVAR (instance-variable) rather than the property itself. The IVAR will always be named _{propertyName}. Referring to the property will cause an infinite loop.

-(void)setMediaItem:(Media *)mediaItem{
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    self.likeButton.likeButtonState = mediaItem.likeState;
    
    
}

-(void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:NO animated:animated];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];
    [super setSelected:NO animated:animated];
    
    
    // Configure the view for the selected state
}

// Instead, we'll use the designated initializer, initWithStyle:reuseIdentifier:. Here we'll initialize the three subviews and add them to self.contentView:
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //iniitialize code
        self.mediaImageView = [[UIImageView alloc] init];
        
        // add the gesture recognizer to the image view
        self.mediaImageView.userInteractionEnabled = YES;
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        
        // initialize the long press recognizer and add it to the image view
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressFired)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
        
        
        
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        
        
        // create teh like button
        self.likeButton = [[LikeButton alloc] init];
        [self.likeButton addTarget:self action:@selector(likePressed) forControlEvents:UIControlEventTouchUpInside];
        self.likeButton.backgroundColor = usernameLabelGray;
       // add the like button to the view hiearchy
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel, self.likeButton]) {

            [self.contentView addSubview:view];

            // this property needs to be set to NO when using auto layout
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton);
        
        // _mediaImageView's leading edge is equal to the content view's leading edge. Their trailing edges are equal too
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|" options:kNilOptions metrics:nil views:viewDictionary]];
        
        // Same as above - setting explicit width  for like button of 38
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel][_likeButton(==38)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDictionary]];
        
        
        // Same as above
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
        
        // The three views should be stacked vertically, from the top, with no space in between.
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];

        
     
        // the height constraints, the setting identifier is optional. It has no effect on your app, but can make it easier to debug auto-layout constraints.
        // the section means "_commentLabel's height is equal to (nothing * 1) + 100."
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:100];
        self.imageHeightConstraint.identifier = @"Image height constraint";
        
        self.usernameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1
                                                                                     constant:100];
        self.usernameAndCaptionLabelHeightConstraint.identifier = @"Username and caption label height constraint";
        
        self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:100];
        self.commentLabelHeightConstraint.identifier = @"Comment label height constraint";
        
        [self.contentView addConstraints:@[self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint]];
        
        
        
        
    }
    return self;
}


#pragma mark - Liking

// inform the delegate when the like button is tapped
-(void) likePressed:(UIButton *)sender{
    
    NSLog(@"Inside likePressed in MTVC line 310..:");
    
    [self.delegate cellDidPressLikeButton:self];
    
    
    
}



// add the target method which will call cell:didTapImageView:
#pragma mark - Image View

-(void) tapFired:(UITapGestureRecognizer *)sender{
    [self.delegate cell:self didTapImageView:self.mediaImageView];
    
    
    
}

// inform the delegate of a long press. We make sure that state is UIGestureRecognizerStateBegan. We could alternatively check for UIGestureRecognizerStateRecognized, but then the method wouldn't get called until the user lifts their finger. (And if we don't check at all, the delegate method will get called twice: once when the recognizer begins, and again when the user lifts their finger.)
- (void) longPressFired:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}

// If the user swipes the cell to show the delete button, and then taps on the cell, the expected behavior is to hide the delete button, not to zoom in on the image. To accomplish this, we'll make sure the gesture recognizer only fires while the cell isn't in editing mode:
-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return self.isEditing == NO;
    
}



// We create a local cell and call layoutSubviews on it. Once that method returns, it is appropriately sized to fit all of its contents. We return the height of our temporary dummy cell.
+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {
    // Make a cell
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
//    
//    // Set it to the given width, and the maximum possible height
//    layoutCell.frame = CGRectMake(0, 0, width, CGFLOAT_MAX);
//    
//    // Give it the media item
    layoutCell.mediaItem = mediaItem;
//    
//    // Make it adjust the image view and labels
//    [layoutCell layoutSubviews];
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    
    // The height will be wherever the bottom of the comments label is
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    // get the actual height required for the cell
    return CGRectGetMaxY(layoutCell.commentLabel.frame);
}





@end
