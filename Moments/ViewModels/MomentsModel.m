//
//  MomentsModel.m
//  Moments
//
//  Created by Thomson on 16/2/18.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "MomentsModel.h"
#import "MomentsCommentCellViewModel.h"

#define kAttach @"attach"
#define kAttachType @"attach_type"
#define kTopic @"content"
#define kComment @"cmt"
#define kHeadImg @"headimg"
#define kUserID @"user_id"
#define kUsername @"user_name"
#define kMomentID @"em_id"
#define kDate @"create_time"
#define kShareContent @"shareContent"
#define kShareImage @"shareHeadimg"

@interface MomentsModel ()

@property (nonatomic, strong, readwrite) NSString *messageType;
@property (nonatomic, strong, readwrite) NSString *topic;
@property (nonatomic, strong, readwrite) NSString *avatarUrl;
@property (nonatomic, strong, readwrite) NSString *username;
@property (nonatomic, strong, readwrite) NSString *userID;
@property (nonatomic, strong, readwrite) NSString *momentID;
@property (nonatomic, strong, readwrite) NSString *date;
@property (nonatomic, strong, readwrite) NSArray  *attachs;
@property (nonatomic, strong, readwrite) NSArray  *comments;

@end

@implementation MomentsModel

+ (instancetype)momentsVOWithDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) return nil;

    MomentsModel *momentVO = [[MomentsModel alloc] init];

    if (momentVO)
    {
        momentVO.messageType = dictionary[kAttachType];
        momentVO.topic = dictionary[kTopic];
        momentVO.avatarUrl = dictionary[kHeadImg];
        momentVO.userID = dictionary[kUserID];
        momentVO.username = dictionary[kUsername];
        momentVO.momentID = dictionary[kMomentID];
        momentVO.date = [MomentsModel dateWithInterval:dictionary[kDate]];
        momentVO.sharedContent = dictionary[kShareContent];
        momentVO.sharedAvatarUrl = dictionary[kShareImage];

        NSArray *attachs = dictionary[kAttach];
        if (attachs && attachs.count > 0)
        {
            momentVO.attachs = [[NSArray alloc] initWithArray:attachs];
        }

        NSArray *comments = dictionary[kComment];
        NSMutableArray *commentsM = [[NSMutableArray alloc] initWithCapacity:0];

        if (comments && comments.count > 0)
        {
            for (NSDictionary *commentDict in comments)
            {
                [commentsM addObject:[MomentsCommentCellViewModel commentVOWithDictionary:commentDict]];
            }
        }

        momentVO.comments = [[NSArray alloc] initWithArray:commentsM];
    }

    return momentVO;
}

+ (NSString *)dateWithInterval:(NSString *)interval
{
    return [Utils timeWithDate:[NSDate dateWithTimeIntervalSince1970:interval.integerValue]];
}

@end
