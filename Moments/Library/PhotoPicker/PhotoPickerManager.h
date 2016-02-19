//
//  PhotoPickerManager.h
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoPickerGroup;

typedef void (^completionBlock)(id obj);

@interface PhotoPickerManager : NSObject

+ (instancetype)defaultManager;

- (void)groupWithType:(NSString *)assetPropertyType
      completionBlock:(completionBlock)block;

- (void)groupWithPhotoPickerGroup:(PhotoPickerGroup *)group
                  completionBlock:(completionBlock)block;

- (void)groupWithURL:(NSURL *)url
     completionBlock:(completionBlock)block;

@end
