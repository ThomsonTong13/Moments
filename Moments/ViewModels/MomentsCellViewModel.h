//
//  MomentsCellViewModel.h
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MomentsModel;
@class MomentsBaseTableViewCell;

@interface MomentsCellViewModel : NSObject

@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *momentID;
@property (nonatomic, strong, readonly) NSArray  *attachs;

@property (nonatomic, strong, readonly) NSArray  *photos;
@property (nonatomic, strong, readonly) NSString *avatarUrl;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *date;
@property (nonatomic, strong, readonly) NSString *messageType;
@property (nonatomic, strong, readonly) NSString *topic;
@property (nonatomic, strong, readonly) NSString *sharedAvatarUrl;
@property (nonatomic, strong, readonly) NSString *sharedContent;

@property (nonatomic, assign, readonly, getter=isValidTopic)  BOOL validTopic;
@property (nonatomic, assign, readonly, getter=isSinglePhoto) BOOL singlePhoto;
@property (nonatomic, assign) BOOL hasComments;

@property (nonatomic, strong) NSArray *comments;

- (instancetype)initWithModel:(MomentsModel *)model;

- (RACSignal *)sendCommentWithParameters:(NSDictionary *)parameters;

- (NSString *)identifier;
- (MomentsBaseTableViewCell *)cellWithIdentifier:(NSString *)reuseIdentifier;
- (CGFloat)estimateHeight;

- (void)getCommentsForMomentsId;

@end
