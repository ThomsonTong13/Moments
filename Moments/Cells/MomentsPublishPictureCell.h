//
//  MomentsPublishPictureCell.h
//  Moments
//
//  Created by Thomson on 16/2/18.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MomentsPublishViewModel;
@protocol MomentsPublishPictureCellDelegate;

@interface MomentsPublishPictureCell : UITableViewCell

@property (nonatomic, weak) id<MomentsPublishPictureCellDelegate> delegate;
@property (nonatomic, strong) MomentsPublishViewModel *viewModel;

+ (CGFloat)estimatedHeightWithViewModel:(MomentsPublishViewModel *)viewModel;

@end

@protocol MomentsPublishPictureCellDelegate <NSObject>

- (void)didSelectAddItem;

@end