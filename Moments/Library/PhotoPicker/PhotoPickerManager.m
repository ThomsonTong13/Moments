//
//  PhotoPickerManager.m
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "PhotoPickerManager.h"
#import "PhotoPickerGroup.h"
#import "PhotoPickerGroupCellViewModel.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoPickerManager ()
@property (nonatomic , strong) ALAssetsLibrary *assetsLibrary;
@end

@implementation PhotoPickerManager
#pragma mark - life cycle

+ (instancetype)defaultManager
{
    static PhotoPickerManager *_instanceManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instanceManager = [[PhotoPickerManager alloc] init];
    });

    return _instanceManager;
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static ALAssetsLibrary *_library = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _library = [[ALAssetsLibrary alloc] init];
    });

    return _library;
}

#pragma mark - public methods

- (void)groupWithType:(NSString *)assetPropertyType completionBlock:(completionBlock)block
{
    __block NSMutableArray *groups = [[NSMutableArray alloc] initWithCapacity:0];

    ALAssetsLibraryGroupsEnumerationResultsBlock resultBlock = ^(ALAssetsGroup *group, BOOL *stop){

        if (group)
        {
            if ([assetPropertyType isEqualToString:ALAssetTypePhoto])
            {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            }
            else if ([assetPropertyType isEqualToString:ALAssetTypeVideo])
            {
                [group setAssetsFilter:[ALAssetsFilter allVideos]];
            }

            PhotoPickerGroup *pickerGroup = [[PhotoPickerGroup alloc] init];
            pickerGroup.group = group;
            pickerGroup.groupName = [group valueForProperty:@"ALAssetsGroupPropertyName"];
            pickerGroup.thumbImage = [UIImage imageWithCGImage:[group posterImage]];
            pickerGroup.assetsCount = [group numberOfAssets];

            [groups addObject:[[PhotoPickerGroupCellViewModel alloc] initWithGroup:pickerGroup]];
        }
        else
        {
            block(groups);
        }
    };

    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                      usingBlock:resultBlock
                                    failureBlock:nil];
}

- (void)groupWithPhotoPickerGroup:(PhotoPickerGroup *)group completionBlock:(completionBlock)block
{
    __block NSMutableArray *assets = [[NSMutableArray alloc] initWithCapacity:0];

    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset , NSUInteger index , BOOL *stop){
        if (asset)
        {
            [assets addObject:asset];
        }
        else
        {
            block(assets);
        }
    };

    [group.group enumerateAssetsUsingBlock:resultsBlock];
}

- (void)groupWithURL:(NSURL *)url completionBlock:(completionBlock)block
{
    [self.assetsLibrary assetForURL:url
                        resultBlock:^(ALAsset *asset) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                block([UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]);
                            });
                        }
                       failureBlock:nil];
}

#pragma mark - getters and setters

- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary)
    {
        _assetsLibrary = [self.class defaultAssetsLibrary];
    }

    return _assetsLibrary;
}

@end
