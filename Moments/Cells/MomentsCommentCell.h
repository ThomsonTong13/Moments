//
//  MomentsCommentCell.h
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MomentsCommentCellViewModel;
@protocol MomentsCommentCellDelegate;

@interface MomentsCommentCell : UITableViewCell

@property (nonatomic, strong) MomentsCommentCellViewModel *viewModel;
@property (nonatomic, weak) id<MomentsCommentCellDelegate> delegate;

@end

@protocol MomentsCommentCellDelegate <NSObject>
- (void)onEvaluateTapped:(MomentsCommentCell *)cell;
@end