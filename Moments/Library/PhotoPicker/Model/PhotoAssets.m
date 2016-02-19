//
//  PhotoAssets.m
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "PhotoAssets.h"

@implementation PhotoAssets

- (UIImage *)thumbImage
{
    return [UIImage imageWithCGImage:[self.asset aspectRatioThumbnail]];
}

- (UIImage *)compressionImage
{
    UIImage *fullScreenImage = [UIImage imageWithCGImage:[[self.asset defaultRepresentation] fullScreenImage]];
    NSData *data = UIImageJPEGRepresentation(fullScreenImage, 0.1);
    UIImage *image = [UIImage imageWithData:data];

    return image;
}

- (UIImage *)originImage
{
    return [UIImage imageWithCGImage:[[self.asset defaultRepresentation] fullScreenImage]];
}

- (NSURL *)assetURL
{
    return [[self.asset defaultRepresentation] url];
}

- (BOOL)isVideoType
{
    NSString *type = [self.asset valueForProperty:ALAssetPropertyType];

    return [type isEqualToString:ALAssetTypeVideo];
}

@end
