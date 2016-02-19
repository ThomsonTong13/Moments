//
//  PhotoPickerCollectionViewCell.m
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "PhotoPickerCollectionViewCell.h"

@implementation PhotoPickerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self.contentView addSubview:self.pickerImageView];
    }

    return self;
}

- (PhotoPickerImageView *)pickerImageView
{
    if (!_pickerImageView)
    {
        _pickerImageView = [[PhotoPickerImageView alloc] initWithFrame:self.bounds];
    }

    return _pickerImageView;
}

@end
