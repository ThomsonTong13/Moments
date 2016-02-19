//
//  MomentsCommentCellViewModel.m
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "MomentsCommentCellViewModel.h"

@interface MomentsCommentCellViewModel ()

@property (nonatomic, strong, readwrite) NSString *commentID;
@property (nonatomic, strong, readwrite) NSString *content;
@property (nonatomic, strong, readwrite) NSString *date;
@property (nonatomic, strong, readwrite) NSString *momentsID;
@property (nonatomic, strong, readwrite) NSString *replyUser;
@property (nonatomic, strong, readwrite) NSString *replyUsername;
@property (nonatomic, strong, readwrite) NSString *userID;
@property (nonatomic, strong, readwrite) NSString *username;

@end

@implementation MomentsCommentCellViewModel

+ (instancetype)commentVOWithDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) return nil;

    MomentsCommentCellViewModel *commentVO = [[MomentsCommentCellViewModel alloc] init];

    if (commentVO)
    {
        commentVO.commentID = dictionary[kCommentID];
        commentVO.content = dictionary[kContent];
        commentVO.momentsID = dictionary[kMomentsID];
        commentVO.replyUser = dictionary[kReplyUser];
        commentVO.replyUsername = dictionary[kReplyUsername];
        commentVO.userID = dictionary[kUserID];
        commentVO.username = dictionary[kUsername];
        commentVO.date = [Utils timeWithDate:[NSDate dateWithTimeIntervalSince1970:[dictionary[kDate] integerValue]]];
    }

    return commentVO;
}

- (CGFloat)estimateHeight
{
    NSString *textToMeasure = self.content;

    UIFont *font = [UIFont systemFontOfSize:13.0f];

    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;

    CGSize contentSize = [textToMeasure boundingRectWithSize:CGSizeMake((kScreenWidth - 130.0), CGFLOAT_MAX)
                                                     options:options
                                                  attributes:@{ NSFontAttributeName :font,NSParagraphStyleAttributeName :paragraphStyle }
                                                     context:nil].size;

    return contentSize.height + 5.0;
}

@end
