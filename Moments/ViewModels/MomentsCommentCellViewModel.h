//
//  MomentsCommentCellViewModel.h
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCommentID @"comment_id"
#define kContent @"content"
#define kDate @"create_time"
#define kReplyUser @"reply_user"
#define kReplyUsername @"reply_user_name"
#define kUserID @"user_id"
#define kUsername @"user_name"
#define kMomentsID @"em_id"

@interface MomentsCommentCellViewModel : NSObject

@property (nonatomic, strong, readonly) NSString *commentID;
@property (nonatomic, strong, readonly) NSString *content;
@property (nonatomic, strong, readonly) NSString *date;
@property (nonatomic, strong, readonly) NSString *momentsID;
@property (nonatomic, strong, readonly) NSString *replyUser;
@property (nonatomic, strong, readonly) NSString *replyUsername;
@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *username;

- (CGFloat)estimateHeight;

+ (instancetype)commentVOWithDictionary:(NSDictionary *)dictionary;

@end
