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



@interface ImagesTableViewController ()


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
    
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
    
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
  
    MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    cell.mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    
    NSLog(@"indexPath.row value..: %lu", indexPath.row);
    
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

        // my additions - instead of deleting the item; move it to the top of the display. Declared the "insertObject...." method in teh DataSource.h file to allow me to call it and then called it to insert the object selected at position zero in the display array and then reloaded the data table with the new array order. Also added “titleForDeleteConfirmation…..” method I found to change the “Delete” text to custom text of moving the item to top of list.

        [[DataSource sharedInstance] insertObject:item inMediaItemsAtIndex:0];
        
        [tableView reloadData];
        
        
        // *** end of my additions
        
//        
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// add this method call to accomodate the change from deleting an item to moving it to the top of the display list
-(NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"Move This Item To Top Of List!";
    
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

@end
