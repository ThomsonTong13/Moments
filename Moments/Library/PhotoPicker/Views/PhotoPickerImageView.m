//
//  PhotoPickerImageView.m
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "PhotoPickerImageView.h"

@interface PhotoPickerImageView ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIImageView *tickImageView;
@property (nonatomic, strong) UIImageView *videoView;

@end

@implementation PhotoPickerImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubview:self.tickImageView];
//        [self addSubview:self.maskView];

        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }

    return self;
}

- (UIView *)maskView
{
    if (!_maskView)
    {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.backgroundColor = [UIColor whiteColor];
        _maskView.alpha = 0.5;
    }

    return _maskView;
}

- (UIImageView *)videoView
{
    if (!_videoView)
    {
        _videoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.bounds.size.height - 40, 30, 30)];
        _videoView.image = [UIImage imageNamed:@"video"];
        _videoView.contentMode = UIViewContentModeScaleAspectFit;
    }

    return _videoView;
}

- (UIImageView *)tickImageView
{
    if (!_tickImageView)
    {
        _tickImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 28, 5, 21, 21)];
        _tickImageView.image = [UIImage imageNamed:@"unselected"];
        [self addSubview:_tickImageView];
    }

    return _tickImageView;
}

- (void)setIsVideoType:(BOOL)isVideoType
{
    _isVideoType = isVideoType;

    self.videoView.hidden = !(isVideoType);
}

- (void)setMaskViewFlag:(BOOL)maskViewFlag
{
    _maskViewFlag = maskViewFlag;

    if (!maskViewFlag)[self.tickImageView setImage:[UIImage imageNamed:@"unselected"]];
    else [self.tickImageView setImage:[UIImage imageNamed:@"selected"]];

    self.animationRightTick = maskViewFlag;
}

- (void)setMaskViewColor:(UIColor *)maskViewColor
{
    _maskViewColor = maskViewColor;

    self.maskView.backgroundColor = maskViewColor;
}

- (void)setMaskViewAlpha:(CGFloat)maskViewAlpha
{
    _maskViewAlpha = maskViewAlpha;

    self.maskView.alpha = maskViewAlpha;
}

- (void)setAnimationRightTick:(BOOL)animationRightTick
{
    _animationRightTick = animationRightTick;
}

@end
