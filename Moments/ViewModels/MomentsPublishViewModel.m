//
//  MomentsPublishViewModel.m
//  Moments
//
//  Created by Thomson on 16/2/18.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "MomentsPublishViewModel.h"
#import "PhotoAssets.h"

@implementation MomentsPublishViewModel

- (instancetype)init
{
    if (self = [super init])
    {
        self.assets = @[];
    }

    return self;
}

- (RACSignal *)publish
{
    return [RACSignal empty];
}

- (RACSignal *)publishContent
{
    return [RACSignal empty];
}

- (PhotoPickerViewModel *)pickerViewModelWithStatus:(PhotoPickerViewShowStatus)status
{
    PhotoPickerViewModel *viewModel = [[PhotoPickerViewModel alloc] initWithStatus:status];
    viewModel.selectAssets = [[NSArray alloc] initWithArray:self.assets];

    return viewModel;
}

@end
