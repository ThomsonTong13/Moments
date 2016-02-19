//
//  PhotoLoadingView.m
//  PhotoBrowser
//
//  Created by Thomson on 15/11/30.
//  Copyright © 2015年 Kemi. All rights reserved.
//

#import "PhotoLoadingView.h"
#import "PhotoProgressView.h"
#import <QuartzCore/QuartzCore.h>

@interface PhotoLoadingView ()

@property (nonatomic, strong) UILabel *failureLabel;
@property (nonatomic, strong) PhotoProgressView *progressView;

@end

@implementation PhotoLoadingView

#pragma mark - life cycle

- (void)setFrame:(CGRect)frame
{
    [super setFrame:[UIScreen mainScreen].bounds];
}

#pragma mark - public methods

- (void)showFailure
{
    [_progressView removeFromSuperview];

    [self addSubview:self.failureLabel];
}

- (void)showLoading
{
    [_failureLabel removeFromSuperview];

    self.progressView.progress = kMinProgress;

    [self addSubview:self.progressView];
}

#pragma mark - private methods

- (void)setProgress:(float)progress
{
    _progress = progress;
    _progressView.progress = progress;

    if (progress >= 1.0)
    {
        [_progressView removeFromSuperview];
    }
}

#pragma mark - getters and setters

- (UILabel *)failureLabel
{
    if (_failureLabel == nil) {
        _failureLabel = [[UILabel alloc] init];
        _failureLabel.bounds = CGRectMake(0, 0, self.bounds.size.width, 44);
        _failureLabel.textAlignment = NSTextAlignmentCenter;
        _failureLabel.center = self.center;
        _failureLabel.text = @"网络不给力，图片下载失败";
        _failureLabel.font = [UIFont boldSystemFontOfSize:20];
        _failureLabel.textColor = [UIColor whiteColor];
        _failureLabel.backgroundColor = [UIColor clearColor];
        _failureLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }

    return _failureLabel;
}

- (PhotoProgressView *)progressView
{
    if (_progressView == nil)
    {
        _progressView = [[PhotoProgressView alloc] init];
        _progressView.bounds = CGRectMake( 0, 0, 60, 60);
        _progressView.center = self.center;
    }

    return _progressView;
}

@end
