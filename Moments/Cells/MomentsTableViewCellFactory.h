//
//  MomentsTableViewCellFactory.h
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MomentsBaseTableViewCell.h"

@class MomentsCellViewModel;

@interface MomentsTableViewCellFactory : NSObject

/**
 *  Create the moments cell by type
 *
 *  @param identifier a NSString
 *
 *  @return MomentsBaseTableViewCell*
 */
+ (MomentsBaseTableViewCell *)cellWithIdentifier:(NSString *)reuseIdentifier;

/**
 *  Pre define cell type with identifier
 *
 *  @param entity a NSManagedObject
 *
 *  @return cell type
 */
+ (NSString *)identifierWithMomentsViewModel:(MomentsCellViewModel *)viewModel;

/**
 *  Estimate the moments cell hight
 *
 *  @param entity a NSManagedObject
 *
 *  @return cell hight
 */
+ (CGFloat)estimateHeightWithMomentsViewModel:(MomentsCellViewModel *)viewModel;

extern NSString * const MomentsMessageTypeTextPlain;
extern NSString * const MomentsMessageTypePicture;
extern NSString * const MomentsMessageTypeShared;

@end
