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
    
//    for (int i = 1; i<= 10; i++) {
//        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
//        UIImage *image = [UIImage imageNamed:imageName];
//        if (image) {
//            [self.images addObject:image];
//            
//        }
//    }
    
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"imageCell"];
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
////#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    //return self.images.count;
    return [DataSource sharedInstance].mediaItems.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
//    // #1 - takes the identifier string and compares it with its roster of registered table view cells. Dequeue will either return:
//    a brand new cell of the type we registered, or
//    a used one that is no longer visible on screen.
//    Cells are recycled as they scroll off screen in order to preserve memory.
    
   // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
    // #2 - configure the cell...set imageViewTag to an arbitrary number - what matters is that it remains consistent. A numerical tag can be attached to any UIView and used later to recover it from its superview by invoking viewWithTag:. This is a quick and dirty way for us to recover the UIImageView which will host the image for this cell.
    
   // static NSInteger imageViewTag = 1234;
    //UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:imageViewTag];
    
    // #3 - we handle the case when viewWithTag: fails to recover a UIImageView. That means it didn't have one and therefore it's a brand new cell. We know it's a new cell because we plan to add a UIImageView to each cell we come across. Therefore, on the second time around, it should already be there.
    
//    if (!imageView) {
//        // this is a new cell, it doesn't have an image view yet
//        imageView = [[UIImageView alloc] init];
//        imageView.contentMode = UIViewContentModeScaleToFill; // UIViewContent... means the image will be stretched both horizontally and vertically to fill the bounds of the UIImageView.
//        
//        imageView.frame = cell.contentView.bounds;
//        
//        // #4 - This property lets its superview know how to resize it when the superview's width or height changes. These are called "bit-wise flags" and we set by OR-ing them together using |.
//        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        
//        // Finally, we set the tag of our new UIImageView before we add it to contentView as a subview.
//        imageView.tag = imageViewTag;
//        [cell.contentView addSubview:imageView];
//        
//    }
    
    
//    UIImage *image = self.images[indexPath.row];
//    imageView.image = image;
//    
//        Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
//        imageView.image = item.image;
//    
  
    MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    cell.mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    
    return cell;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //return 300;
    
    //UIImage *image = self.images[indexPath.row];
    //return image.size.height;
    
    Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
    //UIImage *image = item.image;
    
    //return (CGRectGetWidth(self.view.frame) / image.size.width) * image.size.height;
    //return image.size.height / image.size.width * CGRectGetWidth(self.view.frame);
    //return 300 + (image.size.height / image.size.width * CGRectGetWidth(self.view.frame));
    return [MediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
