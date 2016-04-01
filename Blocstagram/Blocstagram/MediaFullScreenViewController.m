//
//  MediaFullScreenViewController.m
//  Blocstagram
//
//  Created by PT on 2/29/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "MediaFullScreenViewController.h"
#import "Media.h"


@interface MediaFullScreenViewController () <UIScrollViewDelegate>



// properties for the tap and double tap gestures
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;


@end

@implementation MediaFullScreenViewController

-(instancetype) initWithMedia:(Media *)media{
    self = [super init];
   // here in the initializer; store the media for later use
    if (self) {
        self.media = media;
    }
    return self;
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // A scroll view also handles zooming and panning of content. As the user makes a pinch-in or pinch-out gesture, the scroll view adjusts the offset and the scale of the content. When the gesture ends, the object managing the content view should should update subviews of the content as necessary.The UIScrollView class can have a delegate that must adopt the UIScrollViewDelegate protocol. For zooming and panning to work, the delegate must implement both viewForZoomingInScrollView: and scrollViewDidEndZooming:withView:atScale:; in addition, the maximum (maximumZoomScale) and minimum (minimumZoomScale) zoom scale must be different.
    
    
    // set up the scroll vieww and image views
    // create and configure the scroll view
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview: self.scrollView];
    
    // create an image, set the image, and add it as a subview of the scroll view
    self.imageView = [UIImageView new];
    self.imageView.image = self.media.image;
    
    [self.scrollView addSubview: self.imageView];
    
    
    // user the contentSize property to pass in the size of the image
    self.scrollView.contentSize = self.media.image.size;
    
    
    // initialize the tap and double tap gesture properties
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
    // requireGestureRecognizerToFail: allows one gesture recognizer to wait for another gesture recognizer to fail before it succeeds. Without this line, it would be impossible to double-tap because the single tap gesture recognizer would fire before the user had a chance to tap twice.
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    
    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
    
}

-(void) viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    // set scroll view frame to the view's bounds taking up all the views space
    self.scrollView.frame = self.view.bounds;
    
    
    [self recalculateZoomScale];
}

- (void) recalculateZoomScale {
    
    
    
    
    // look at the ratio of the scroll views width to the images width and the ration of the scrool views height to the image's height
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    //The two lines we added divide the size dimensions by self.scrollView.zoomScale. This allows subclasses to recalculate the zoom scale for scroll views that are zoomed out.
    scrollViewContentSize.height /= self.scrollView.zoomScale;
    scrollViewContentSize.width /= self.scrollView.zoomScale;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1;
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// this method will center the image on the appropriate axis as it is zoomed in and out
- (void)centerScrollView {
    [self.imageView sizeToFit];
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - CGRectGetWidth(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.x = 0;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - CGRectGetHeight(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.y = 0;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark - UIScrollViewDelegate
// #6 - tells the scroll view which view to zoom in and out on.
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

// #7 - calls centerScrollView after the user has changed the zoom level.
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollView];
}

// this method is to make sure the image starts out centered
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self centerScrollView];
}

#pragma mark - Gesture Recognizers

// when user single taps dismiss the view controller
-(void) tapFired:(UIGestureRecognizer *) sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

// when user double taps you adjust the zoom level
- (void) doubleTapFired:(UITapGestureRecognizer *)sender {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        // #8 If the current zoom scale is already as small as it can be, double-tapping will zoom in. This works by calculating a rectangle using the user's finger as a center point, and telling the scroll view to zoom in on that rectangle.
        CGPoint locationPoint = [sender locationInView:self.imageView];
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        CGFloat x = locationPoint.x - (width / 2);
        CGFloat y = locationPoint.y - (height / 2);
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
    } else {
        // #9 - If the current zoom scale is larger then zoom out to the minimum scale.
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
