//
//  ImageLibraryViewController.m
//  Blocstagram
//
//  Created by PT on 3/31/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "ImageLibraryViewController.h"
#import <Photos/Photos.h>
#import "CropImageViewController.h"

// adding comments

@interface ImageLibraryViewController ()


@property (nonatomic, strong) PHFetchResult *result; // result is a PHFetchResult. It acts like a high performance array of image assets. Unlike an array, it doesn't store the images in memory at once, but rather "fetches objects from the backing store in chunks on demand".

@end

@implementation ImageLibraryViewController

- (instancetype) init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    
    return [super initWithCollectionViewLayout:layout];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    UIImage *cancelImage = [UIImage imageNamed:@"x"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void) cancelPressed:(UIBarButtonItem *)sender {
    [self.delegate imageLibraryViewController:self didCompleteWithImage:nil];
}

static NSString * const reuseIdentifier = @"Cell";

//At layout time, we calculate the size of each cell. We want to fit as many as possible on each row, without going below 100 points. We don't put any spacing between cells, and we set our header to be 30 points high.

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat minWidth = 100;
    NSInteger divisor = width / minWidth;
    CGFloat cellSize = width / divisor;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(cellSize, cellSize);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
}

//PHFetchOptions specifies a wide variety of different options developers can use when retrieving photo entities. In this case, we're only specifying that they should be sorted by creationDate. See the class reference for additional options.
- (void) loadAssets {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    self.result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
}

//In viewWillAppear:, we ask PHPhotoLibrary whether the user has already granted access to their photo library. If not, we request authorization. Once the user authorizes, we load the assets and reload the collection view on the main thread. If the user has already authorized, we just load the assets: there's no need to reload.
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadAssets];
                    [self.collectionView reloadData];
                });
            }
        }];
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self loadAssets];
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

// We only have one section, so we can delete numberOfSectionsInCollectionView:
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//#warning Incomplete method implementation -- Return the number of sections
//    return 0;
//}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.result.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSInteger imageViewTag = 54321;
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:imageViewTag];
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.tag = imageViewTag;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
    }
    
    if (cell.tag != 0) {
        [[PHImageManager defaultManager] cancelImageRequest:(PHImageRequestID)cell.tag];
    }
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    PHAsset *asset = self.result[indexPath.row];
    
    cell.tag = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:flowLayout.itemSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        UICollectionViewCell *cellToUpdate = [collectionView cellForItemAtIndexPath:indexPath];
        
        if (cellToUpdate) {
            UIImageView *imageView = (UIImageView *)[cellToUpdate.contentView viewWithTag:imageViewTag];
            imageView.image = result;
        }
    }];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.result[indexPath.row];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *resultImage, NSDictionary *info)
     {
         CropImageViewController *cropVC = [[CropImageViewController alloc] initWithImage:resultImage];
         cropVC.delegate = self;
         [self.navigationController pushViewController:cropVC animated:YES];
     }];
    
}

#pragma mark - CropImageViewControllerDelegate

- (void) cropControllerFinishedWithImage:(UIImage *)croppedImage {
    [self.delegate imageLibraryViewController:self didCompleteWithImage:croppedImage];
}


/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
