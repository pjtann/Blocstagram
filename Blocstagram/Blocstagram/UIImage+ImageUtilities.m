//
//  UIImage+ImageUtilities.m
//  Blocstagram
//
//  Created by PT on 3/30/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "UIImage+ImageUtilities.h"

@implementation UIImage (ImageUtilities)

//UIImages are often stored rotated and/or mirrored.This method inspects the image's imageOrientation property and uses this information to flip or rotate the image as necessary. transform holds an "affine transformation matrix" a grid of numbers (like a spreadsheet) that describes how to rotate, flip, and scale a 2D image. We update it to reflect how we want to rotate/flip/scale the image.
//Once transform is set, we:
//
// 1. Create a CGContextRef(a "bitmap graphics context", like a blank sheet of paper you can draw on)
// 2. Scale the image (to support Retina displays)
// 3. Apply transform to the drawing context with CGContextConcatCTM, and
// 4. Draw the transformed image from the graphics context using CGContextDrawImage.
//We then create a UIImage from the CGImageRef and return it.

- (UIImage *) imageWithFixedOrientation {
    // Do nothing if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return [self copy];
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGFloat scaleFactor = self.scale;
    
    
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             self.size.width * scaleFactor,
                                             self.size.height * scaleFactor,
                                             CGImageGetBitsPerComponent(self.CGImage),
                                             0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    
    CGContextScaleCTM(ctx, scaleFactor, scaleFactor);
    
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0, self.size.width, self.size.height), self.CGImage);
            break;
    }
    
    // Create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg scale:scaleFactor orientation:UIImageOrientationUp];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}



// Resizing images to match the aspect ratio The aspect ratio of the iOS device's screen is not the same as the aspect ratio of the iOS device's camera. We'll need to resize an image to the aspect ratio of the screen in order to make the cropping rectangle accurate. We calculate the aspect ratio (ratio) and use that to calculate the size of the resized image (newSize). We create a new drawing context in the appropriate size and draw the image on it. Finally, we use the same steps as before to get a CGImageRef and convert that to a UIImage.

- (UIImage *) imageResizedToMatchAspectRatioOfSize:(CGSize)size {
    CGFloat horizontalRatio = size.width / self.size.width;
    CGFloat verticalRatio = size.height / self.size.height;
    CGFloat ratio = MAX(horizontalRatio, verticalRatio);
    CGSize newSize = CGSizeMake(self.size.width * ratio * self.scale, self.size.height * ratio * self.scale);
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = self.CGImage;
    
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             newRect.size.width,
                                             newRect.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage),
                                             0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    
    // Draw into the context; this scales the image
    CGContextDrawImage(ctx, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(ctx);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:self.scale orientation:UIImageOrientationUp];
    
    // Clean up
    CGContextRelease(ctx);
    CGImageRelease(newImageRef);
    
    return newImage;
}


// Finally, one more action we'll need to perform: cropping. This method is the simplest because CGImageCreateWithImageInRect does the work for us. We use it to create the cropped image, convert to UIImage, and return the result.
- (UIImage *) imageCroppedToRect:(CGRect)cropRect {
    cropRect.size.width *= self.scale;
    cropRect.size.height *= self.scale;
    cropRect.origin.x *= self.scale;
    cropRect.origin.y *= self.scale;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return image;
}





@end
