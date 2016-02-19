//
//  PhotoPickerGroupCellViewModel.m
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "PhotoPickerGroupCellViewModel.h"
#import "PhotoPickerGroup.h"

@implementation PhotoPickerGroupCellViewModel

- (instancetype)initWithGroup:(PhotoPickerGroup *)group
{
    if (self = [super init])
    {
        self.group = group;
    }

    return self;
}

@end
