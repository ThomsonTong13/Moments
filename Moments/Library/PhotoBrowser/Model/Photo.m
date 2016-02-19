//
//  Photo.m
//  PhotoBrowser
//
//  Created by Thomson on 15/11/30.
//  Copyright © 2015年 Kemi. All rights reserved.
//

#import "Photo.h"

@implementation Photo

- (UIImage *)capture:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (void)setSrcImageView:(UIImageView *)srcImageView
{
    _srcImageView = srcImageView;
    _placeholder = srcImageView.image;

    if (srcImageView.clipsToBounds) _capture = [self capture:srcImageView];
}

- (void)setImage:(UIImage *)image
{
    _image = image;

    _placeholder = image;
}

@end
