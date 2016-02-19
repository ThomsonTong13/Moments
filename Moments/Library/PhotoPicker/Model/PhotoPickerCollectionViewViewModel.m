//
//  PhotoPickerCollectionViewViewModel.m
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "PhotoPickerCollectionViewViewModel.h"
#import "PhotoAssets.h"

@implementation PhotoPickerCollectionViewViewModel

- (BOOL)photoIsSelected:(PhotoAssets *)assets
{
    __block BOOL isContains = NO;

    [self.selectAssets enumerateObjectsUsingBlock:^(PhotoAssets *allAssets, NSUInteger idx, BOOL *stop) {

        if ([allAssets.assetURL isEqual:assets.assetURL])
        {
            isContains = YES;
            *stop = YES;
        }
    }];

    return isContains;
}

- (void)removeSelectedAssets:(PhotoAssets *)assets
{
    NSMutableArray *selectAssetsM = [[NSMutableArray alloc] initWithArray:self.selectAssets];
    [selectAssetsM enumerateObjectsUsingBlock:^(PhotoAssets *selectAssets, NSUInteger idx, BOOL *stop) {

        if ([selectAssets.assetURL isEqual:assets.assetURL])
        {
            [selectAssetsM removeObject:selectAssets];
            *stop = YES;
        }
    }];

    self.selectAssets = [[NSArray alloc] initWithArray:selectAssetsM];
}

- (void)addSelectedAssets:(PhotoAssets *)assets
{
    NSMutableArray *selectAssetsM = [[NSMutableArray alloc] initWithArray:self.selectAssets];
    [selectAssetsM addObject:assets];
    self.selectAssets = [[NSArray alloc] initWithArray:selectAssetsM];
}

@end
