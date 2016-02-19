//
//  PhotoView.h
//  PhotoBrowser
//
//  Created by Thomson on 15/11/30.
//  Copyright © 2015年 Kemi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Photo, PhotoView;

@protocol PhotoViewDelegate <NSObject>

- (void)photoViewImageFinishLoad:(PhotoView *)photoView;
- (void)photoViewSingleTap:(PhotoView *)photoView;
- (void)photoViewDidEndZoom:(PhotoView *)photoView;

@end

@interface PhotoView : UIScrollView

@property (nonatomic, strong) Photo *photo;
@property (nonatomic, weak) id<PhotoViewDelegate> photoViewDelegate;

@end
