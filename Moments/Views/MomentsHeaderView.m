//
//  MomentsHeaderView.m
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MomentsHeaderView.h"
#import "MomentsViewModel.h"

static CGFloat kUserImageSize = 50;
static CGFloat kUserImageBottomMargin = 18;
static CGFloat kUserImageLeftMargin = 15;
static CGFloat kUserLabelLeftMargin = 15;

@interface MomentsHeaderView ()

@property (nonatomic, strong) UIScrollView *headerScrollView;
@property (nonatomic, strong) UILabel *usernameText;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIView *avatarBackgroundView;

@end

@implementation MomentsHeaderView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];
    }

    return self;
}

#pragma mark - event response

- (void)onAvatarTapped:(UIGestureRecognizer *)recognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onAvatarTapped:)])
    {
        [self.delegate onAvatarTapped:self];
    }
}

#pragma mark - public methods

- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset
{
    if (offset.y <= 0)
    {
        CGFloat delta = 0.0f;
        CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        delta = fabs(MIN(0.0f, offset.y));
        rect.origin.y -= delta;
        rect.size.height += delta;
        self.headerScrollView.frame = rect;
        self.clipsToBounds = NO;
    }
}

#pragma mark - private methods

- (void)initialSetup
{
    [self configViews];
    [self setupLayoutConstraint];
    [self setupActionBind];
}

- (void)configViews
{
    [self addSubview:self.headerScrollView];
    [self.headerScrollView addSubview:self.coverImageView];
    [self addSubview:self.usernameText];
    [self addSubview:self.avatarBackgroundView];
    [self.avatarBackgroundView addSubview:self.avatarView];

    self.backgroundColor = [UIColor whiteColor];
}

- (void)setupLayoutConstraint
{
    @weakify(self);
    [self.avatarBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.left.equalTo(self).with.offset(kUserImageLeftMargin);
        make.bottom.equalTo(self.mas_bottom).with.offset(-(kUserImageBottomMargin));
        make.width.equalTo(@(kUserImageSize));
        make.height.equalTo(@(kUserImageSize));
    }];

    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.edges.equalTo(self.avatarBackgroundView).with.insets(UIEdgeInsetsMake(2, 2, 2, 2));
    }];

    [self.usernameText mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.left.equalTo(self.avatarView.mas_right).with.offset(kUserLabelLeftMargin);
        make.bottom.equalTo(self.avatarView.mas_bottom);
    }];
}

- (void)setupActionBind
{
    @weakify(self);
    [[RACObserve(self, viewModel)
      filter:^BOOL(id value) {

          return value != nil;
      }]
      subscribeNext:^(MomentsViewModel *viewModel) {

          @strongify(self);
          self.usernameText.text = viewModel.userName;

          [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:viewModel.momentBackgroundImageUrl]
                                 placeholderImage:nil
                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           
                                        }];
         
          [self.avatarView sd_setImageWithURL:[NSURL URLWithString:viewModel.userImageUrl]
                             placeholderImage:nil
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       
                                    }];
     }];
}

#pragma mark - getters and setters

- (UIScrollView *)headerScrollView
{
    if (!_headerScrollView)
    {
        _headerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _headerScrollView.backgroundColor = [UIColor clearColor];
    }

    return _headerScrollView;
}

- (UIImageView *)coverImageView
{
    if (!_coverImageView)
    {
        _coverImageView = [[UIImageView alloc] initWithFrame:self.headerScrollView.bounds];
        _coverImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.backgroundColor = [UIColor clearColor];
    }

    return _coverImageView;
}

- (UIImageView *)avatarView
{
    if (!_avatarView)
    {
        _avatarView = [UIImageView new];
        _avatarView.contentMode = UIViewContentModeScaleToFill;
        _avatarView.backgroundColor = [UIColor clearColor];
        _avatarView.layer.cornerRadius = (kUserImageSize - 2) / 2.0;
        _avatarView.clipsToBounds = YES;
        _avatarView.userInteractionEnabled = YES;

        UITapGestureRecognizer *onTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarTapped:)];
        [_avatarView addGestureRecognizer:onTap];
    }

    return _avatarView;
}

- (UIView *)avatarBackgroundView
{
    if (!_avatarBackgroundView)
    {
        _avatarBackgroundView = [UIView new];
        _avatarBackgroundView.backgroundColor = [UIColor whiteColor];
        _avatarBackgroundView.layer.cornerRadius = kUserImageSize / 2.0;
        _avatarBackgroundView.clipsToBounds = YES;
    }

    return _avatarBackgroundView;
}

- (UILabel *)usernameText
{
    if (!_usernameText)
    {
        _usernameText = [UILabel new];
        _usernameText.textAlignment = NSTextAlignmentLeft;
        _usernameText.numberOfLines = 1;
        _usernameText.lineBreakMode = NSLineBreakByWordWrapping;
        _usernameText.textColor = [UIColor whiteColor];
        _usernameText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
        _usernameText.backgroundColor = [UIColor clearColor];
    }

    return _usernameText;
}

@end
