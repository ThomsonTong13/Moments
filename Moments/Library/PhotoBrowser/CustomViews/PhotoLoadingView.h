//
//  PhotoLoadingView.h
//  PhotoBrowser
//
//  Created by Thomson on 15/11/30.
//  Copyright © 2015年 Kemi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMinProgress 0.0001

@interface PhotoLoadingView : UIView

@property (nonatomic) float progress;

- (void)showLoading;
- (void)showFailure;

@end
