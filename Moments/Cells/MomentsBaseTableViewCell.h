//
//  MomentsBaseTableViewCell.h
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MomentsCellViewModel;
@class MomentsCommentCellViewModel;
@protocol MomentsCellDelegate;

@interface MomentsBaseTableViewCell : UITableViewCell

@property (nonatomic, strong) MomentsCellViewModel *viewModel;
@property (nonatomic, weak) id<MomentsCellDelegate> delegate;

+ (CGFloat)estimateHeightWithViewModel:(MomentsCellViewModel *)viewModel;

@end

@interface MomentsTextTableViewCell : MomentsBaseTableViewCell

@end

@interface MomentsImageTableViewCell : MomentsTextTableViewCell

@end

@interface MomentsSharedTableViewCell : MomentsTextTableViewCell

@end

@protocol MomentsCellDelegate <NSObject>

- (void)onImageTapped:(MomentsCellViewModel *)viewModel;
- (void)onLabelTapped:(MomentsCellViewModel *)viewModel;
- (void)onEvaluateButtonTapped:(MomentsBaseTableViewCell *)cell;
- (void)onReplyTapped:(MomentsBaseTableViewCell *)cell viewModel:(MomentsCommentCellViewModel *)viewModel;
- (void)onDeleteButtonTapped:(MomentsCellViewModel *)viewModel;

@end