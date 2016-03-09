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




@interface ImagesTableViewController () <MediaTableViewCellDelegate> // indicates this class conforms to the protocol created in the MediaTableViewCell files



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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
    
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
        return 350;
    } else {
        return 150;
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


@end
