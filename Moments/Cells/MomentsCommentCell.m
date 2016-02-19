//
//  MomentsCommentCell.m
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <CoreText/CoreText.h>

#import "MomentsCommentCell.h"
#import "MomentsCommentCellViewModel.h"

@interface MomentsCommentCell ()

@property (strong, nonatomic) UILabel *commentLabel;

@end

@implementation MomentsCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self)
    {
        [self.contentView addSubview:self.commentLabel];

        @weakify(self);
        [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {

            @strongify(self);
            make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(5.0, 10.0, 0, 5.0));
        }];

        self.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.selectionStyle = UITableViewCellSelectionStyleGray;

        [[RACObserve(self, viewModel)
          filter:^BOOL(id value) {
              return value != nil;
          }]
          subscribeNext:^(MomentsCommentCellViewModel *viewModel) {

              @strongify(self);
              if (viewModel.replyUsername && viewModel.replyUsername.length > 0)
              {
                  NSString *content = [NSString stringWithFormat:@"%@ 回复 %@：%@", viewModel.username, viewModel.replyUsername, viewModel.content];

                  NSValue *value1 = [NSValue valueWithRange:[content rangeOfString:viewModel.username]];
                  NSValue *value2 = [NSValue valueWithRange:[content rangeOfString:viewModel.replyUsername]];

                  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
                  [attributedString addAttributes:@{ NSForegroundColorAttributeName: [Utils HexColorToRedGreenBlue:@"#6b9aa2"]}
                                            range:value1.rangeValue];
                  [attributedString addAttributes:@{ NSForegroundColorAttributeName: [Utils HexColorToRedGreenBlue:@"#6b9aa2"]}
                                            range:value2.rangeValue];

                  self.commentLabel.attributedText = attributedString;
             }
             else
             {
                 NSString *content = [NSString stringWithFormat:@"%@：%@", viewModel.username, viewModel.content];
                 NSRange range = [content rangeOfString:viewModel.username];

                 NSValue *value = [NSValue valueWithRange:range];

                 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
                 [attributedString addAttributes:@{ NSForegroundColorAttributeName: [Utils HexColorToRedGreenBlue:@"#6b9aa2"]}
                                           range:value.rangeValue];

                 self.commentLabel.attributedText = attributedString;
             }
         }];
    }

    return self;
}

- (UILabel *)commentLabel
{
    if (!_commentLabel)
    {
        _commentLabel = [UILabel new];
        _commentLabel.backgroundColor = [UIColor clearColor];
        _commentLabel.textColor = [Utils HexColorToRedGreenBlue:@"#404040"];
        _commentLabel.font = [UIFont systemFontOfSize:13.f];
        _commentLabel.userInteractionEnabled = YES;

        @weakify(self);
        UITapGestureRecognizer *onTap = [[UITapGestureRecognizer alloc] init];
        [[onTap rac_gestureSignal] subscribeNext:^(id x) {

            @strongify(self);

            if (self.delegate && [self.delegate respondsToSelector:@selector(onEvaluateTapped:)])
            {
                [self.delegate onEvaluateTapped:self];
            }
        }];

        [_commentLabel addGestureRecognizer:onTap];
    }

    return _commentLabel;
}

@end
