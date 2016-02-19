//
//  MomentsTableViewCellFactory.m
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "MomentsTableViewCellFactory.h"
#import "MomentsCellViewModel.h"

NSString * const MomentsMessageTypeTextPlain = @"textPlain";
NSString * const MomentsMessageTypePicture = @"picture";
NSString * const MomentsMessageTypeShared = @"share";

@implementation MomentsTableViewCellFactory

#pragma mark - public methods

+ (NSString *)identifierWithMomentsViewModel:(MomentsCellViewModel *)viewModel
{
    return NSStringFromClass([self classWithViewModel:viewModel]);
}

+ (MomentsBaseTableViewCell *)cellWithIdentifier:(NSString *)reuseIdentifier
{
    Class class = NSClassFromString(reuseIdentifier);

    return [[class alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

+ (CGFloat)estimateHeightWithMomentsViewModel:(MomentsCellViewModel *)viewModel
{
    Class class = [self classWithViewModel:viewModel];

    return class == [self class] ? 0.f: [class estimateHeightWithViewModel:viewModel];
}

#pragma mark - private methods

+ (Class)classWithViewModel:(MomentsCellViewModel *)viewModel
{
    Class class = [self class];

    if (!viewModel) return class;

    NSString *messageType = viewModel.messageType;

    if ([messageType isEqualToString:MomentsMessageTypeTextPlain])
    {
        class = [MomentsTextTableViewCell class];
    }
    else if ([messageType isEqualToString:MomentsMessageTypePicture])
    {
        class = [MomentsImageTableViewCell class];
    }
    else if ([messageType isEqualToString:MomentsMessageTypeShared])
    {
        class = [MomentsSharedTableViewCell class];
    }

    return class;
}

@end
