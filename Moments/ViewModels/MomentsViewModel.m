//
//  MomentsViewModel.m
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "MomentsViewModel.h"
#import "MomentsCellViewModel.h"
#import "MomentsCommentCellViewModel.h"
#import "MomentsPublishViewModel.h"
#import "MomentsModel.h"

#define kUser @"user"
#define kList @"data_list"
#define kUsername @"user_name"
#define kHeadImg @"headimg"
#define kHomePage @"homepage_head"

@interface MomentsViewModel ()

@property (nonatomic, strong, readwrite) NSString *userName;
@property (nonatomic, strong, readwrite) NSString *momentBackgroundImageUrl;
@property (nonatomic, strong, readwrite) NSString *userImageUrl;

@end

@implementation MomentsViewModel

- (RACSignal *)loadNextPage
{
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground];

    @weakify(self);

    return [[RACSignal
             createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

                 @strongify(self);

                 NSString *plist = [[NSBundle mainBundle] pathForResource:@"Moments" ofType:@"plist"];

                 NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:plist];

                 NSDictionary *userInfo = data[kUser];

                 self.userName = userInfo[kUsername];
                 self.userImageUrl = userInfo[kHeadImg];
                 self.momentBackgroundImageUrl = userInfo[kHomePage];

                 NSArray *dataList = data[kList];

                 NSMutableArray *momentListM = [[NSMutableArray alloc] initWithArray:self.momentList];

                 for (NSDictionary *momentDict in dataList)
                 {
                     MomentsCellViewModel *viewModel = [[MomentsCellViewModel alloc] initWithModel:[MomentsModel momentsVOWithDictionary:momentDict]];

                     [momentListM addObject:viewModel];
                 }

                 self.momentList = [[NSArray alloc] initWithArray:momentListM];

                 [subscriber sendNext:self.momentList];
                 [subscriber sendCompleted];

                 return nil;
             }]
             deliverOn:scheduler];
}

- (RACSignal *)removeMoments:(NSString *)momentsId
{
    return [[RACSignal
             createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

                 NSMutableArray *momentsM = [[NSMutableArray alloc] initWithArray:self.momentList];
                 __block MomentsCellViewModel *removeViewModel = nil;

                 [momentsM enumerateObjectsUsingBlock:^(MomentsCellViewModel *viewModel, NSUInteger idx, BOOL *stop) {

                     if ([viewModel.momentID isEqualToString:momentsId])
                     {
                         removeViewModel = viewModel;
                         *stop = YES;
                     }
                 }];

                 if (removeViewModel)
                 {
                     [momentsM removeObject:removeViewModel];
                     self.momentList = [[NSArray alloc] initWithArray:momentsM];
                 }

                 [subscriber sendNext:@"Succeed"];
                 [subscriber sendCompleted];
                 
                 return nil;
             }]
             deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]];
}

- (void)updateMomentListAtIndexPath:(NSIndexPath *)indexPath parameters:(NSDictionary *)parameters
{
}

#pragma mark - Getters & Setters

- (NSArray *)momentList
{
    if (!_momentList)
    {
        _momentList = [[NSArray alloc] init];
    }

    return _momentList;
}

- (MomentsPublishViewModel *)publishViewModel
{
    return [[MomentsPublishViewModel alloc] init];
}

@end
