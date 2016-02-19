//
//  MomentsHeaderView.h
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MomentsViewModel;
@protocol MomentsHeaderViewDelegate;

@interface MomentsHeaderView : UIView

- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset;

@property (nonatomic, weak) id<MomentsHeaderViewDelegate> delegate;
@property (nonatomic, strong) MomentsViewModel *viewModel;

@end


@protocol MomentsHeaderViewDelegate <NSObject>
- (void)onAvatarTapped:(id)object;
@end