//
//  PhotoPickerGroupCellViewModel.h
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoPickerGroup;

@interface PhotoPickerGroupCellViewModel : NSObject

@property (nonatomic, strong) PhotoPickerGroup *group;

- (instancetype)initWithGroup:(PhotoPickerGroup *)group;

@end
