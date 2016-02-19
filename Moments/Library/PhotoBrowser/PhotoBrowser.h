//
//  PhotoBrowser.h
//  PhotoBrowser
//
//  Created by Thomson on 15/11/30.
//  Copyright © 2015年 Kemi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBrowser;

@protocol PhotoBrowserDelegate <NSObject>

@optional
// 切换到某一页图片
- (void)photoBrowser:(PhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;

@end

@interface PhotoBrowser : UIViewController

- (instancetype)initWithPhotos:(NSArray *)photos;

@property (nonatomic, weak)   id<PhotoBrowserDelegate> delegate;
@property (nonatomic, assign) NSUInteger currentPhotoIndex; //当前展示的图片索引

// 显示
- (void)show;

@end
