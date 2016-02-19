//
//  MomentsCellViewModel.m
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "MomentsCellViewModel.h"
#import "MomentsCommentCellViewModel.h"

#import "MomentsModel.h"

#import "MomentsTableViewCellFactory.h"

@interface MomentsCellViewModel ()

@property (nonatomic, strong, readwrite) MomentsModel *model;

@property (nonatomic, strong, readwrite) NSString *userID;
@property (nonatomic, strong, readwrite) NSString *momentID;
@property (nonatomic, strong, readwrite) NSArray  *attachs;

@property (nonatomic, strong, readwrite) NSArray  *photos;

@property (nonatomic, strong, readwrite) NSString *avatarUrl;
@property (nonatomic, strong, readwrite) NSString *username;
@property (nonatomic, strong, readwrite) NSString *date;
@property (nonatomic, strong, readwrite) NSString *messageType;
@property (nonatomic, strong, readwrite) NSString *topic;

@property (nonatomic, strong, readwrite) NSString *sharedAvatarUrl;
@property (nonatomic, strong, readwrite) NSString *sharedContent;

@property (nonatomic, assign, readwrite, getter=isValidTopic)  BOOL validTopic;
@property (nonatomic, assign, readwrite, getter=isSinglePhoto) BOOL singlePhoto;

@end

@implementation MomentsCellViewModel

- (instancetype)initWithModel:(MomentsModel *)model
{
    self = [super init];

    if (self)
    {
        self.username = model.username;
        self.userID = model.userID;
        self.momentID = model.momentID;
        self.date = model.date;
        self.avatarUrl = model.avatarUrl;
        self.messageType = model.messageType;
        self.sharedContent = model.sharedContent;
        self.sharedAvatarUrl = model.sharedAvatarUrl;
        self.topic = model.topic;
        self.comments = model.comments;
        self.attachs = model.attachs;

        self.validTopic = (model.topic && model.topic.length > 0) ? YES: NO;
        self.hasComments = (model.comments && model.comments.count > 0) ? YES: NO;
        self.singlePhoto = (model.attachs && model.attachs.count > 1) ? NO: YES;

        self.model = model;

        @weakify(self);
        [[self downloadImageWithURLs:self.attachs]
         subscribeNext:^(NSArray *images) {

             @strongify(self);
             self.photos = [[NSArray alloc] initWithArray:images];
         }];

        [[RACObserve(self, comments)
          filter:^BOOL(id value) {

              return value != nil;
          }]
          subscribeNext:^(NSArray *comments) {

              @strongify(self);

              if (comments.count > 0)
              {
                  self.hasComments = YES;
              }
         }];
    }

    return self;
}

- (RACSignal *)downloadImageWithURLs:(NSArray *)urls
{
    __block NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:0];

    return [[RACSignal
             createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

                 [urls enumerateObjectsUsingBlock:^(NSString *downloadURL, NSUInteger idx, BOOL *stop) {

                     [[self downloadImageWithURL:downloadURL] subscribeNext:^(RACTuple *tuple) {

                         UIImage *image = tuple.first;
                         NSString *url = tuple.second;

                         if ([downloadURL isEqualToString:url])
                         {
                             [images addObject:image];
                         }

                         if (images.count == urls.count)
                         {
                             [subscriber sendNext:images];
                             [subscriber sendCompleted];
                         }
                     }];
                 }];

                 return nil;
             }]
            deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]];
}

- (RACSignal *)downloadImageWithURL:(NSString *)url
{
    return [RACSignal
            createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

                NSURL *URL = [NSURL URLWithString:url];
                [[SDWebImageManager sharedManager] downloadImageWithURL:URL
                                                                options:SDWebImageLowPriority|SDWebImageRetryFailed
                                                               progress:nil
                                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {

                                                                  RACTuple *tuple = [RACTuple tupleWithObjects:image, url, nil];
                                                                  [subscriber sendNext:tuple];
                                                                  [subscriber sendCompleted];
                                                              }];

                return nil;
            }];
}

- (RACSignal *)sendCommentWithParameters:(NSDictionary *)parameters
{
    return [RACSignal empty];
}

- (NSString *)identifier
{
    return [MomentsTableViewCellFactory identifierWithMomentsViewModel:self];
}

- (MomentsBaseTableViewCell *)cellWithIdentifier:(NSString *)reuseIdentifier
{
    return [MomentsTableViewCellFactory cellWithIdentifier:reuseIdentifier];
}

- (CGFloat)estimateHeight
{
    return [MomentsTableViewCellFactory estimateHeightWithMomentsViewModel:self];
}

- (void)getCommentsForMomentsId
{
    
}

@end
