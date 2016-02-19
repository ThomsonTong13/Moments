//
//  PhotoPickerGroup.h
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

@interface PhotoPickerGroup : NSObject

/**
 *  组名
 */
@property (nonatomic, copy) NSString *groupName;

/**
 *  缩略图
 */
@property (nonatomic, strong) UIImage *thumbImage;

/**
 *  组里面的图片个数
 */
@property (nonatomic, assign) NSInteger assetsCount;

/**
 *  类型 : Saved Photos...
 */
@property (nonatomic , copy) NSString *type;

@property (nonatomic , strong) ALAssetsGroup *group;


@end
