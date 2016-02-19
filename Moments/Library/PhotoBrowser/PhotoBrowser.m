//
//  PhotoBrowser.m
//  PhotoBrowser
//
//  Created by Thomson on 15/11/30.
//  Copyright © 2015年 Kemi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PhotoBrowser.h"
#import "PhotoView.h"
#import "Photo.h"
#import "SDWebImageManager.h"
#import "UtilsMacors.h"

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

static NSInteger pageControlHeight = 40;

@interface PhotoBrowser () <PhotoViewDelegate, UIScrollViewDelegate>
{
    BOOL _statusBarHiddenInited; //一开始的状态栏
}

@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSMutableSet *visiblePhotoViews;
@property (nonatomic, strong) NSMutableSet *reusablePhotoViews;

@property (nonatomic, strong) NSArray *items;

@end

@implementation PhotoBrowser
#pragma mark - life cycle

- (instancetype)initWithPhotos:(NSArray *)items
{
    self.items = items;
    
    return [super init];
}

- (void)loadView
{
    _statusBarHiddenInited = [UIApplication sharedApplication].isStatusBarHidden;
    // 隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.photoScrollView];
    [self.view addSubview:self.pageControl];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self showPhotos];

    _currentPhotoIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.pageControl.currentPage = _currentPhotoIndex;
}

#pragma mark - KMPhotoViewDelegate

- (void)photoViewSingleTap:(PhotoView *)photoView
{
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHiddenInited withAnimation:UIStatusBarAnimationNone];
    self.view.backgroundColor = [UIColor clearColor];

    [self.pageControl removeFromSuperview];
}

- (void)photoViewDidEndZoom:(PhotoView *)photoView
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)photoViewImageFinishLoad:(PhotoView *)photoView
{
    self.pageControl.currentPage = _currentPhotoIndex;
}

#pragma mark - public methods

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];

    [self showPhotos];
    self.pageControl.currentPage = _currentPhotoIndex;
}

#pragma mark - private methods

- (void)showPhotos
{
    // 只有一张图片
    if (_items.count == 1)
    {
        [self showPhotoViewAtIndex:0];
        return;
    }

    CGRect visibleBounds = _photoScrollView.bounds;
    NSInteger firstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _items.count) firstIndex = _items.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _items.count) lastIndex = _items.count - 1;

    // 回收不再显示的ImageView
    NSInteger photoViewIndex;
    for (PhotoView *photoView in self.visiblePhotoViews)
    {
        photoViewIndex = kPhotoViewIndex(photoView);
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex)
        {
            [self.reusablePhotoViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }

    [self.visiblePhotoViews minusSet:self.reusablePhotoViews];
    while (self.reusablePhotoViews.count > 2)
    {
        [self.reusablePhotoViews removeObject:[self.reusablePhotoViews anyObject]];
    }

    for (NSUInteger index = firstIndex; index <= lastIndex; index++)
    {
        if (![self isShowingPhotoViewAtIndex:index])
        {
            [self showPhotoViewAtIndex:index];
        }
    }
}

- (void)showPhotoViewAtIndex:(NSInteger)index
{
    PhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView)
    {
        photoView = [[PhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }

    // 调整当期页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;

    Photo *photo = _items[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;

    [self.visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];

    // 自动下载前后两张图片
    [self loadImageNearIndex:index];
}

- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index
{
    for (PhotoView *photoView in _visiblePhotoViews)
    {
        if (kPhotoViewIndex(photoView) == index) return YES;
    }

    return  NO;
}

- (void)loadImageNearIndex:(NSInteger)index
{
    if (index > 0)
    {
        Photo *photo = _items[index - 1];
        if (photo.url)
        {
            [self downloadImageWithURL:photo.url];
        }
    }

    if (index < _items.count - 1)
    {
        Photo *photo = _items[index + 1];
        if (photo.url)
        {
            [self downloadImageWithURL:photo.url];
        }
    }
}

- (PhotoView *)dequeueReusablePhotoView
{
    PhotoView *photoView = [self.reusablePhotoViews anyObject];
    if (photoView) [self.reusablePhotoViews removeObject:photoView];

    return photoView;
}

- (void)downloadImageWithURL:(NSURL *)url
{
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url
                                                          options:SDWebImageLowPriority|SDWebImageRetryFailed
                                                         progress:nil
                                                        completed:nil];
}

#pragma mark - getters and setters

- (UIScrollView *)photoScrollView
{
    if (!_photoScrollView)
    {
        CGRect frame = self.view.bounds;
        frame.origin.x -= kPadding;
        frame.size.width += (2 * kPadding);

        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.delegate = self;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.backgroundColor = [UIColor clearColor];
        _photoScrollView.contentSize = CGSizeMake(frame.size.width * _items.count, 0);
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * frame.size.width, 0);
    }

    return _photoScrollView;
}

- (UIPageControl *)pageControl
{
    if (_pageControl)
    {
        return _pageControl;
    }

    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kScreenHeight - pageControlHeight, kScreenWidth, pageControlHeight)];
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.userInteractionEnabled = NO;
    _pageControl.enabled = NO;
    _pageControl.numberOfPages = _items.count;

    return _pageControl;
}

- (NSMutableSet *)reusablePhotoViews
{
    if (!_reusablePhotoViews)
    {
        _reusablePhotoViews = [NSMutableSet set];
    }

    return _reusablePhotoViews;
}

- (NSMutableSet *)visiblePhotoViews
{
    if (!_visiblePhotoViews)
    {
        _visiblePhotoViews = [NSMutableSet set];
    }

    return _visiblePhotoViews;
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;

    for (int i = 0; i < _items.count; i++)
    {
        Photo *photo = _items[i];
        photo.index = i;
        photo.firstShow = (i == currentPhotoIndex);
    }
}

@end
