//
//  PhotoView.m
//  PhotoBrowser
//
//  Created by Thomson on 15/11/30.
//  Copyright © 2015年 Kemi. All rights reserved.
//

#import "PhotoView.h"
#import "Photo.h"
#import "PhotoLoadingView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"

@interface PhotoView () <UIScrollViewDelegate>
{
    BOOL _doubleTap;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PhotoLoadingView *photoLoadingView;

@end

@implementation PhotoView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.clipsToBounds = YES;
        [self addSubview:self.imageView];

        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];

        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
    }

    return self;
}

- (void)dealloc
{
    // 取消请求
    [_imageView sd_cancelCurrentImageLoad];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;

    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - event response

- (void)handleSingleTap:(UITapGestureRecognizer *)tap
{
    _doubleTap = NO;

    [self performSelector:@selector(hide) withObject:nil afterDelay:0.2];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap
{
    _doubleTap = YES;

    CGPoint touchPoint = [tap locationInView:self];

    if (self.zoomScale == self.maximumZoomScale)
    {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else
    {
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}

#pragma mark - private methods

- (void)showImage
{
    [self.photoLoadingView removeFromSuperview];

    // 首次显示
    if (self.photo.firstShow)
    {
        self.imageView.image = self.photo.placeholder; //默认图片

        if (![self.photo.url.absoluteString hasSuffix:@"gif"])
        {
            __unsafe_unretained PhotoView *photoView = self;
            __unsafe_unretained Photo *photo = self.photo;

            [self.imageView sd_setImageWithURL:self.photo.url
                              placeholderImage:self.photo.placeholder
                                       options:SDWebImageRetryFailed|SDWebImageLowPriority
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         if (image)
                                             photo.image = image;

                                         [photoView adjustFrame];
                                     }];
        }
    }
    else
    {
        [self photoStartLoad];
    }

    [self adjustFrame];
}

- (void)adjustFrame
{
    if (_imageView.image == nil) return;

    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;

    CGSize imageSize = _imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;

    // 设置伸缩比例
    CGFloat minScale = boundsWidth / imageWidth;
    if (minScale > 1) minScale = 1.0;

    CGFloat maxScale = 3.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) maxScale = maxScale / [[UIScreen mainScreen] scale];

    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;

    CGRect imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    // 内容尺寸
    self.contentSize = CGSizeMake(0, imageFrame.size.height);

    // y值
    if (imageFrame.size.height < boundsHeight)
    {
        imageFrame.origin.y = floorf((boundsHeight - imageFrame.size.height) / 2.0);
    }
    else
    {
        imageFrame.origin.y = 0;
    }

    if (_photo.firstShow)
    {
        //第一次显示的图片
        _photo.firstShow = NO;
        _imageView.frame = self.photo.originBounds;

        [UIView animateWithDuration:0.3
                         animations:^{

                             _imageView.frame = imageFrame;
                         }
                         completion:^(BOOL finished) {

                             [self photoStartLoad];
                         }];
    }
    else
    {
        _imageView.frame = imageFrame;
    }
}

- (void)photoStartLoad
{
    if (_photo.image)
    {
        self.scrollEnabled = YES;
        _imageView.image = _photo.image;
    }
    else
    {
        self.scrollEnabled = NO;

        // 直接显示进度条
        [self addSubview:self.photoLoadingView];
        [self.photoLoadingView showLoading];

        __unsafe_unretained PhotoView *photoView = self;
        __unsafe_unretained PhotoLoadingView *loading = _photoLoadingView;

        [_imageView sd_setImageWithURL:_photo.url
                      placeholderImage:_photo.srcImageView.image
                               options:SDWebImageRetryFailed|SDWebImageLowPriority
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {

                                  if (receivedSize > kMinProgress)
                                  {
                                      loading.progress = (float)receivedSize/expectedSize;
                                  }
                              }
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

                                 [photoView photoDidFinishLoadWithImage:image];
                             }];
    }
}

- (void)photoDidFinishLoadWithImage:(UIImage *)image
{
    if (image)
    {
        self.scrollEnabled = YES;
        _photo.image = image;
        [_photoLoadingView removeFromSuperview];

        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)])
        {
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    }
    else
    {
        [self addSubview:self.photoLoadingView];
        [self.photoLoadingView showFailure];
    }

    // 设置缩放比例
    [self adjustFrame];
}

- (void)hide
{
    if (_doubleTap) return;

    // 移除进度条
    [_photoLoadingView removeFromSuperview];
    self.contentOffset = CGPointZero;

    [self reset];

    [UIView animateWithDuration:0.5
                     animations:^{
                         _imageView.frame = self.photo.originBounds;

                         // gif图片仅显示第0张
                         if (_imageView.image.images)
                         {
                             _imageView.image = _imageView.image.images[0];
                         }

                         // 通知代理
                         if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)])
                         {
                             [self.photoViewDelegate photoViewSingleTap:self];
                         }
                     }
                     completion:^(BOOL finished) {

                         // 通知代理
                         if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidEndZoom:)])
                         {
                             [self.photoViewDelegate photoViewDidEndZoom:self];
                         }
                     }];
}

- (void)reset
{
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
}

#pragma mark - getters and setters

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }

    return _imageView;
}

- (void)setPhoto:(Photo *)photo
{
    _photo = photo;

    [self showImage];
}

- (PhotoLoadingView *)photoLoadingView
{
    if (!_photoLoadingView)
    {
        _photoLoadingView = [[PhotoLoadingView alloc] init];
    }

    return _photoLoadingView;
}

@end
