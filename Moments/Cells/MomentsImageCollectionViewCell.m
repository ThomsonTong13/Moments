//
//  MomentsImageCollectionViewCell.m
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "MomentsImageCollectionViewCell.h"

@implementation MomentsImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self.contentView addSubview:self.imageView];

        @weakify(self);
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {

            @strongify(self);
            make.edges.equalTo(self.contentView);
        }];

        self.contentView.backgroundColor = [UIColor clearColor];
    }

    return self;
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }

    return _imageView;
}

@end
