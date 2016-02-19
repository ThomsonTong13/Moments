//
//  MomentsModel.h
//  Moments
//
//  Created by Thomson on 16/2/18.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MomentsModel : NSObject

@property (nonatomic, strong, readonly) NSString *messageType;
@property (nonatomic, strong, readonly) NSString *topic;
@property (nonatomic, strong, readonly) NSString *avatarUrl;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *momentID;
@property (nonatomic, strong, readonly) NSString *date;
@property (nonatomic, strong, readonly) NSArray  *attachs;
@property (nonatomic, strong, readonly) NSArray  *comments;

@property (nonatomic, strong) NSString *sharedAvatarUrl;
@property (nonatomic, strong) NSString *sharedContent;

+ (instancetype)momentsVOWithDictionary:(NSDictionary *)dictionary;

@end
