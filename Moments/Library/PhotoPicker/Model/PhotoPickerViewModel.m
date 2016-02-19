//
//  PhotoPickerViewModel.m
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "PhotoPickerViewModel.h"
#import "PhotoPickerCollectionViewViewModel.h"
#import "PhotoPickerGroupCellViewModel.h"
#import "PhotoPickerManager.h"
#import "PhotoAssets.h"

#import "ReactiveCocoa.h"

@interface PhotoPickerViewModel ()

@property (nonatomic, assign, readwrite) PhotoPickerViewShowStatus status;
@property (nonatomic, strong, readwrite) NSArray *groups;
@property (nonatomic, strong, readwrite) NSArray *assets;

@end

@implementation PhotoPickerViewModel

- (instancetype)initWithStatus:(PhotoPickerViewShowStatus)status
{
    if (self = [super init])
    {
        self.status = status;
        self.maxCount = 9;

        RACChannelTo(self, assets) = RACChannelTo(self.collectionViewViewModel, assets);
        RACChannelTo(self, selectAssets) = RACChannelTo(self.collectionViewViewModel, selectAssets);
    }

    return self;
}

- (void)fetchGroupsWithCompletionBlock:(CompletionBlock)block
{
    PhotoPickerManager *manager = [PhotoPickerManager defaultManager];

    NSString *assetType = nil;
    if (self.status == PhotoPickerViewShowStatusVideo)
    {
        assetType = ALAssetTypeVideo;
    }
    else
    {
        assetType = ALAssetTypePhoto;
    }

    @weakify(self);
    [manager groupWithType:assetType
           completionBlock:^(NSArray *groups) {

               NSMutableArray *groupsM = [[NSMutableArray alloc] initWithCapacity:0];

               for (PhotoPickerGroupCellViewModel *viewModel in groups)
               {
                   if (viewModel.group.assetsCount > 0)
                   {
                       [groupsM addObject:viewModel];
                   }
               }

               @strongify(self);
               self.groups = [[NSArray alloc] initWithArray:groupsM];
               block();
           }];
}

- (void)fetchAssets
{
    __block NSMutableArray *assetsM = [[NSMutableArray alloc] initWithCapacity:0];

    @weakify(self);
    [[PhotoPickerManager defaultManager] groupWithPhotoPickerGroup:self.assetsGroup
                                                     completionBlock:^(NSArray *assets) {
                                                         
                                                         @strongify(self);
                                                         [assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop) {

                                                             PhotoAssets *photoAssets = [[PhotoAssets alloc] init];
                                                             photoAssets.asset = asset;
                                                             [assetsM addObject:photoAssets];
                                                         }];

                                                         self.assets = [[NSArray alloc] initWithArray:assetsM];
                                                     }];
}

- (PhotoPickerCollectionViewViewModel *)collectionViewViewModel
{
    if (!_collectionViewViewModel)
    {
        _collectionViewViewModel = [[PhotoPickerCollectionViewViewModel alloc] init];
        _collectionViewViewModel.status = PhotoPickerCollectionViewShowOrderStatusTimeDesc;
        _collectionViewViewModel.maxCount = self.maxCount;
        _collectionViewViewModel.selectAssets = [[NSArray alloc] initWithArray:self.selectAssets];
    }

    return _collectionViewViewModel;
}

@end
