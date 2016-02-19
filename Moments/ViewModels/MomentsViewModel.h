//
//  MomentsViewModel.h
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MomentsPublishViewModel;

@interface MomentsViewModel : NSObject

@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSString *momentBackgroundImageUrl;
@property (nonatomic, strong, readonly) NSString *userImageUrl;

@property (nonatomic, strong) NSArray *momentList;

- (RACSignal *)loadNextPage;
- (RACSignal *)removeMoments:(NSString *)momentsId;
- (void)updateMomentListAtIndexPath:(NSIndexPath *)indexPath parameters:(NSDictionary *)parameters;

- (MomentsPublishViewModel *)publishViewModel;

@end
