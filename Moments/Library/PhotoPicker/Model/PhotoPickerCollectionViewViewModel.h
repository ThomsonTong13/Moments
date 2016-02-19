//
//  PhotoPickerCollectionViewViewModel.h
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoAssets;

// 展示状态
typedef NS_ENUM(NSUInteger, PhotoPickerCollectionViewShowOrderStatus){
    PhotoPickerCollectionViewShowOrderStatusTimeDesc = 0, // 升序
    PhotoPickerCollectionViewShowOrderStatusTimeAsc // 降序
};

@interface PhotoPickerCollectionViewViewModel : NSObject

@property (nonatomic, assign) PhotoPickerCollectionViewShowOrderStatus status;
// 保存所有的数据
@property (nonatomic, strong) NSArray *assets;
// 保存选中的图片
@property (nonatomic, strong) NSArray *selectAssets;
// 最后保存的一次图片
@property (strong,nonatomic) NSMutableArray *lastDataArray;
// 限制最大数
@property (nonatomic, assign) NSInteger maxCount;
// 选中的索引值，为了防止重用
@property (nonatomic, strong) NSMutableArray *selectsIndexPath;
// 记录选中的值
@property (assign,nonatomic) BOOL isRecoderSelectPicker;

- (BOOL)photoIsSelected:(PhotoAssets *)assets;

- (void)removeSelectedAssets:(PhotoAssets *)assets;

- (void)addSelectedAssets:(PhotoAssets *)assets;

@end
