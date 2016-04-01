//
//  ImagesTableViewController.m
//  Blocstagram
//
//  Created by PT on 1/12/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "DataSource.h"
#import "Media.h"
#import "User.h"
#import "Comment.h"
#import "MediaTableViewCell.h"
#import "MediaFullScreenViewController.h"
#import "CameraViewController.h"
#import "CameraViewController.h"
#import "ImageLibraryViewController.h"



@interface ImagesTableViewController () <MediaTableViewCellDelegate, CameraViewControllerDelegate> // indicates this class conforms to the protocol created in the MediaTableViewCell files and the camera view


@property (nonatomic, weak) UIImageView *lastTappedImageView;

@property (nonatomic, weak) UIView *lastSelectedCommentView;
@property (nonatomic, assign) CGFloat lastKeyboardAdjustment;


@end

@implementation ImagesTableViewController

-(id) initWithStyle:(UITableViewStyle)style{
    
    self = [super initWithStyle:style];
    if (self) {
        // custom initialization
        //self.images = [NSMutableArray array];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
    
    // to support the pull-to-refresh action of pulling down the screen to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControldidFire:) forControlEvents:UIControlEventValueChanged];
    
    
    
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    
    //In viewDidLoad, we'll request notifications of the keyboard appearing and disappearing. We'll also enable UIScrollViewKeyboardDismissModeInteractive, which lets the user slide the keyboard down like in the Messages app.
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    // check if any photo capabilities at all are available, and if so, add a camera button. (The camera button won't appear in the simulator.)
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraPressed:)];
        self.navigationItem.rightBarButtonItem = cameraButton;
    }
    
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
    // unregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// supports the pull-to-refresh action
-(void) refreshControldidFire:(UIRefreshControl *) sender{
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error){
     // The only thing our code block does ([sender endRefreshing];) is tell the UIRefreshControl to stop spinning and hide itself.
        
        [sender endRefreshing];
    }];
    
     
}

// At #3, infiniteScrollIfNecessary checks whether or not the user has scrolled to the last photo. This is accomplished by inspecting an array of NSIndexPath objects which represent the cells visible on screen. We call lastObject on the NSArray returned by indexPathsForVisibleRows to recover the index path of the cell shown at the very bottom of the table. If that cell represents the last image in the _mediaItems array, we call requestOldItemsWithCompletionHandler: in order to recover more.
-(void) infiniteScrollIfNecessary{
    // #3
    NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
    if (bottomIndexPath && bottomIndexPath.row == [DataSource sharedInstance].mediaItems.count - 1) {
        // the very last cell is on the screen
        [[DataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
        
    }
}

#pragma mark - UIScrollViewDelegate

// #4 - needs a little more explanation. UITableView is a subclass of UIScrollView. A scroll view, plainly stated, is a UI element which scrolls. When its content size is larger than its frame, a pan gesture moves its content. A scroll view can be scrolled horizontally and/or vertically. (A table view is locked into vertical-only scrolling.) The scroll view has a delegate protocol with many methods in it, one of which is scrollViewDidScroll:. This delegate method is invoked when the scroll view is scrolled in any direction. As the user scrolls the table view, this method will be called repeatedly. It's a good place to check whether or not the last image in our array has made it onto the screen.
-(void) scrollViewDidScroll:(UIScrollView *)scrollView  {
    [self infiniteScrollIfNecessary];
    
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"mediaItems"]) {
        // we know mediaItems has changed so let's see what kind of change it is
        NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        
        NSLog(@"Value of change dictionary constant - kindOfChange..: %lu", (unsigned long)kindOfChange);
        
        if (kindOfChange == NSKeyValueChangeSetting){
            // someone set a brand new images array
            [self.tableView reloadData];

            // The comments below refer to the else if statements starting below these comments
            // This else if block checks to make sure that the change which occurred is one of the remaining options: insert, remove or replace. We recover an NSIndexSet for each modified index. For example, if images 2 and 3 were removed from mediaItems, those two values would be found in this set.
            
            //We create and provide an NSArray of NSIndexPath objects at #1 to update the table view's rows. All the rows are in a single section and are ordered by their location in the mediaItems array. Therefore, we enumerate indexSetOfChanges and add to a brand new array, indexPathsThatChanged.
            
            //#2: Before we tell the table which rows have been modified, removed or inserted, we prepare it for updates by calling beginUpdates. This lets the table accumulate the modifications we pass to it in preparation for when we call its complementary method, endUpdates. Once endUpdates is invoked, the table takes all of the changes made to its underlying structure since beginUpdates was called and animates itself to represent the new structure.
            
        } else if (kindOfChange == NSKeyValueChangeInsertion ||
                         kindOfChange == NSKeyValueChangeRemoval ||
                         kindOfChange == NSKeyValueChangeReplacement) {
        // We have an incremental change: inserted, deleted, or replaced images
        
        // Get a list of the index (or indices) that changed
        NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
        
        // #1 - Convert this NSIndexSet to an NSArray of NSIndexPaths (which is what the table view animation methods require) add the objects at those indexes that have changed to this new array
        NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
        [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [indexPathsThatChanged addObject:newIndexPath];
        }];
        
        // #2 - Call `beginUpdates` to tell the table view we're about to make changes
        [self.tableView beginUpdates];
        
        // Tell the table view what the changes are
        if (kindOfChange == NSKeyValueChangeInsertion) {
            [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
        } else if (kindOfChange == NSKeyValueChangeRemoval) {
            [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
        } else if (kindOfChange == NSKeyValueChangeReplacement) {
            [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        // Tell the table view that we're done telling it about changes, and to complete the animation
        [self.tableView endUpdates];
            
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






 #pragma mark - Camera, CameraViewControllerDelegate, and ImageLibraryViewControllerDelegate
// When the button is pressed, present the view controller within a navigation controller and dismiss it with a note when the delegate method is called:
- (void) cameraPressed:(UIBarButtonItem *) sender {

    UIViewController *imageVC;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        CameraViewController *cameraVC = [[CameraViewController alloc] init];
        cameraVC.delegate = self;
        imageVC = cameraVC;
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        ImageLibraryViewController *imageLibraryVC = [[ImageLibraryViewController alloc] init];
        imageLibraryVC.delegate = self;
        imageVC = imageLibraryVC;
    }
    
    if (imageVC) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imageVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    return;
}

- (void) cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image {
    [cameraViewController dismissViewControllerAnimated:YES completion:^{
        if (image) {
            NSLog(@"Got an image!");
        } else {
            NSLog(@"Closed without an image.");
        }
    }];
}







#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.

    return [DataSource sharedInstance].mediaItems.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
   
  
    MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    
    // set delegate for creating or dequeing cells
    cell.delegate = self;
    
    cell.mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    
    return cell;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];

    return [MediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
        [[DataSource sharedInstance] deleteMediaItem:item];
//        
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

//If a row is tapped, let's assume the user doesn't want the keyboard:
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaTableViewCell *cell = (MediaTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell stopComposingComment];
}



// method to check whether we need images right before a cell displays. A tableview sends this message/method to it's delegate just before it uses "cell" to draw a row
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    Media *mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
        [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
        
    }
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
    if (item.image) {
        return 450;
    } else {
        return 250;
    }
}

#pragma mark - MediaTableViewCellDelegate

-(void) cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView {
    MediaFullScreenViewController *fullScreenVC = [[MediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    
    [self presentViewController:fullScreenVC animated:YES completion:nil];
    
}

// long press method - This will share an image (and a caption if there is one). UIActivityViewController is passed an array of items to share, and then it's presented.
- (void) cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (cell.mediaItem.caption.length > 0) {
        [itemsToShare addObject:cell.mediaItem.caption];
    }
    
    if (cell.mediaItem.image) {
        [itemsToShare addObject:cell.mediaItem.image];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

// set cell.mediaItem which updates the like button's appearance
- (void) cellDidPressLikeButton:(MediaTableViewCell *)cell {
    Media *item = cell.mediaItem;
    
    [[DataSource sharedInstance] toggleLikeOnMediaItem:item withCompletionHandler:^{
        if (cell.mediaItem == item) {
            cell.mediaItem = item;
        }
    }];
    
    cell.mediaItem = item;
}


- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    
}

//If the user starts composing a comment, we'll store a reference to the comment view. If the user presses the comment button, we'll tell the API to send a comment.
- (void) cellWillStartComposingComment:(MediaTableViewCell *)cell {
    self.lastSelectedCommentView = (UIView *)cell.commentView;
}

- (void) cell:(MediaTableViewCell *)cell didComposeComment:(NSString *)comment {
    [[DataSource sharedInstance] commentOnMediaItem:cell.mediaItem withCommentText:comment];
}

#pragma mark - Keyboard Handling
//When the keyboard shows, we need to do a few things:We need to determine if the keyboard will obscure the comment view's text box. (This will happen if the user taps a comment on the lower half of the screen).If the keyboard will obscure the comment view, adjust the table view's content insets and offset to move the comment view directly above the keyboard.If we make any changes, save them for later so we can undo them when the keyboard hides.
//Let's step through the code. We get the keyboard's frame and the comment view's frame, and make sure they're in the same coordinate system. If the keyboard would be higher on the screen than the comment view, we account for the positioning difference. If the two frames intersect, we adjust the height by the amount of their intersection. Finally, we animate the changes, and store the adjustment for future use. When the keyboard hides, we reverse these changes:

- (void)keyboardWillShow:(NSNotification *)notification {
    // Get the frame of the keyboard within self.view's coordinate system
    NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameInScreenCoordinates = frameValue.CGRectValue;
    CGRect keyboardFrameInViewCoordinates = [self.navigationController.view convertRect:keyboardFrameInScreenCoordinates fromView:nil];
    
    // Get the frame of the comment view in the same coordinate system
    CGRect commentViewFrameInViewCoordinates = [self.navigationController.view convertRect:self.lastSelectedCommentView.bounds fromView:self.lastSelectedCommentView];
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    CGFloat heightToScroll = 0;
    
    CGFloat keyboardY = CGRectGetMinY(keyboardFrameInViewCoordinates);
    CGFloat commentViewY = CGRectGetMinY(commentViewFrameInViewCoordinates);
    CGFloat difference = commentViewY - keyboardY;
    
    if (difference > 0) {
        heightToScroll += difference;
    }
    
    if (CGRectIntersectsRect(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates)) {
        // The two frames intersect (the keyboard would block the view)
        CGRect intersectionRect = CGRectIntersection(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates);
        heightToScroll += CGRectGetHeight(intersectionRect);
    }
    
    if (heightToScroll > 0) {
        contentInsets.bottom += heightToScroll;
        scrollIndicatorInsets.bottom += heightToScroll;
        contentOffset.y += heightToScroll;
        
        NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        
        NSTimeInterval duration = durationNumber.doubleValue;
        UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
        UIViewAnimationOptions options = curve << 16;
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
            self.tableView.contentOffset = contentOffset;
        } completion:nil];
    }
    
    self.lastKeyboardAdjustment = heightToScroll;
}


- (void) imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image {
    [imageLibraryViewController dismissViewControllerAnimated:YES completion:^{
        if (image) {
            NSLog(@"Got an image!");
        } else {
            NSLog(@"Closed without an image.");
        }
    }];
}



@end
