//
//  ImageLibraryViewController.h
//  Blocstagram
//
//  Created by PT on 3/31/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ImageLibraryViewController;

@protocol ImageLibraryViewControllerDelegate <NSObject>

- (void) imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image;

@end

@interface ImageLibraryViewController : UICollectionViewController

@property (nonatomic, weak) NSObject <ImageLibraryViewControllerDelegate> *delegate;

@end
