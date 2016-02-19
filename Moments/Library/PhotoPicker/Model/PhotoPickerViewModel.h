//
//  PhotoPickerViewModel.h
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoPickerGroup.h"

@class PhotoPickerCollectionViewViewModel;

typedef void(^CompletionBlock)(void);

typedef NS_ENUM(NSInteger, PhotoPickerViewShowStatus) {
    PhotoPickerViewShowStatusGroup = 0,
    PhotoPickerViewShowStatusCameraRoll,
    PhotoPickerViewShowStatusSavePhotos,
    PhotoPickerViewShowStatusPhotoStream,
    PhotoPickerViewShowStatusAllPhoto,
    PhotoPickerViewShowStatusVideo
};

@interface PhotoPickerViewModel : NSObject

@property (nonatomic, assign, readonly) PhotoPickerViewShowStatus status;
@property (nonatomic, strong, readonly) NSArray *groups;
@property (nonatomic, strong, readonly) NSArray *assets;
@property (nonatomic, strong) NSArray *selectAssets;
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, strong) PhotoPickerGroup *assetsGroup;
@property (nonatomic, strong) PhotoPickerCollectionViewViewModel *collectionViewViewModel;

- (instancetype)initWithStatus:(PhotoPickerViewShowStatus)status;
- (void)fetchGroupsWithCompletionBlock:(CompletionBlock)block;
- (void)fetchAssets;

@end
