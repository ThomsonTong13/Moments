//
//  MomentsBaseTableViewCell.m
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "MomentsBaseTableViewCell.h"
#import "MomentsCellViewModel.h"
#import "MomentsCommentCellViewModel.h"

#import "MomentsImageCollectionViewCell.h"
#import "MomentsCommentCell.h"

#import "Photo.h"
#import "PhotoBrowser.h"

typedef NS_ENUM(NSUInteger, MomentsItemSpace) {
    MomentsHeadImageHorizontalMargin = 15,
    MomentsHeadImageSize = 40,
    MomentsHeadImageVerticalMargin = 15,
    MomentsUsernameTextTopMargin = 20,
    MomentsUsernameTextRightMargin = 5,
    MomentsUsernameTextHeight = 15,
    MomentsCommentTopMargin = 14,
    MomentsCommentButtonSize = 14,
    MomentsTopicTextTopMargin = 6,
    MomentsTopicTextHeight = 16,
    MomentsSharedViewTopMargin = 9,
    MomentsSharedViewHeight = 50,
    MomentsSharedViewPadding = 5,
    MomentsSharedImageSize = 40,
    MomentsTableViewTopMargin = 5
};

static NSString * const collectionCellIdentifier = @"collectionCellIdentifier";
static NSString * const commentCellIdentifier = @"commentCellIdentifier";

@interface MomentsBaseTableViewCell () <UITableViewDataSource, UITableViewDelegate, MomentsCommentCellDelegate>

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *usernameText;
@property (nonatomic, strong) UILabel *timeText;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *commentCoverButton;

@property (nonatomic, strong) MASConstraint *commentButtonTopConstraint;
@property (nonatomic, strong) MASConstraint *tableViewHeightConstraint;

- (void)configViews;
- (void)setupLayoutConstraint;
- (void)setupActionBind;

@end

@interface MomentsTextTableViewCell ()

@property (nonatomic, strong) UILabel *topicText;
@property (nonatomic, strong) MASConstraint *contentLabelHeightConstraint;

+ (CGFloat)getTopicHeightWithViewModel:(MomentsCellViewModel *)viewModel;

@end

@interface MomentsImageTableViewCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *imageCollectionView;

@property (nonatomic, strong) MASConstraint *collectionViewHeightConstraint;
@property (nonatomic, strong) MASConstraint *collectionViewTopConstraint;

@end

@interface MomentsSharedTableViewCell ()

@property (nonatomic, strong) UILabel *shareText;
@property (nonatomic, strong) UIView  *shareBackground;
@property (nonatomic, strong) UILabel *shareContents;
@property (nonatomic, strong) UIImageView *shareAvatarView;

@property (nonatomic, strong) MASConstraint *shareTopConstraint;

@end

@implementation MomentsBaseTableViewCell

#pragma mark - life cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self configViews];
        [self setupLayoutConstraint];
        [self setupActionBind];

        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MomentsCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];

    if (!cell)
    {
        cell = [[MomentsCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentCellIdentifier];
        cell.delegate = self;
    }

    cell.viewModel = self.viewModel.comments[indexPath.row];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MomentsCommentCellViewModel *viewModel = self.viewModel.comments[indexPath.row];

    CGFloat height = [viewModel estimateHeight];

    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MomentsCommentCellViewModel *viewModel = self.viewModel.comments[indexPath.row];

    CGFloat height = [viewModel estimateHeight];

    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];

    if (!view)
    {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
    }

    if (self.viewModel.comments && self.viewModel.comments.count > 0)
    {
        view.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    else
    {
        view.contentView.backgroundColor = [UIColor whiteColor];
    }

    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"footer"];

    if (!view)
    {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"footer"];
        view.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    MomentsCommentCellViewModel *viewModel = self.viewModel.comments[indexPath.row];

    if (self.delegate && [self.delegate respondsToSelector:@selector(onReplyTapped:viewModel:)])
    {
        [self.delegate onReplyTapped:self viewModel:viewModel];
    }
}

#pragma mark - MomentsCommentCellDelegate

- (void)onEvaluateTapped:(MomentsCommentCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - private methods

- (void)configViews
{
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.usernameText];
    [self.contentView addSubview:self.timeText];
    [self.contentView addSubview:self.commentButton];
    [self.contentView addSubview:self.commentCoverButton];
    [self.contentView addSubview:self.deleteButton];
    [self.contentView addSubview:self.bottomLine];
    [self.contentView addSubview:self.tableView];
}

- (void)setupLayoutConstraint
{
    @weakify(self);
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.top.equalTo(self.contentView.mas_top).with.offset(MomentsHeadImageVerticalMargin);
        make.left.equalTo(self.contentView.mas_left).with.offset(MomentsHeadImageHorizontalMargin);
        make.width.equalTo(@(MomentsHeadImageSize));
        make.height.equalTo(@(MomentsHeadImageSize));
    }];

    [self.usernameText mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.top.equalTo(self.contentView.mas_top).with.offset(MomentsUsernameTextTopMargin);
        make.left.equalTo(self.avatarView.mas_right).with.offset(MomentsHeadImageHorizontalMargin);
        make.height.equalTo(@(MomentsUsernameTextHeight));
    }];

    [self.timeText mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.centerY.equalTo(self.commentButton.mas_centerY);
        make.left.equalTo(self.usernameText.mas_left);
    }];

    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.centerY.equalTo(self.timeText.mas_centerY);
        make.left.equalTo(self.timeText.mas_right).with.offset(15);
    }];

    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        self.commentButtonTopConstraint = make.top.equalTo(self.usernameText.mas_bottom).with.offset(MomentsCommentTopMargin);
        make.right.equalTo(self.contentView.mas_right).with.offset(-20);
    }];

    [self.commentCoverButton mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
        make.center.equalTo(self.commentButton);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.top.equalTo(self.commentButton.mas_bottom).with.offset(MomentsTableViewTopMargin);
        make.left.equalTo(self.avatarView.mas_right).with.offset(MomentsHeadImageHorizontalMargin);
        make.right.equalTo(self.contentView.mas_right).with.offset(-20);
        self.tableViewHeightConstraint = make.height.equalTo(@0);
    }];

    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.left.and.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@1);
    }];
}

- (void)setupActionBind
{
    RAC(self.usernameText, text) = RACObserve(self, viewModel.username);
    RAC(self.timeText, text) = RACObserve(self, viewModel.date);

    @weakify(self);
    [RACObserve(self, viewModel.avatarUrl)
     subscribeNext:^(NSString *url) {

         @strongify(self);
         [self.avatarView sd_setImageWithURL:[NSURL URLWithString:url]
                            placeholderImage:[UIImage imageNamed:@"avatar_default_big"]];
     }];

    [RACObserve(self, viewModel.userID)
     subscribeNext:^(NSString *uid) {

         @strongify(self);
         [self.deleteButton setAlpha:1];
     }];
    
    [[RACObserve(self, viewModel.comments)
      filter:^BOOL(id value) {

          return value != nil;
      }]
      subscribeNext:^(id _) {

          @strongify(self);
          [self setNeedsUpdateConstraints];
          [self updateConstraintsIfNeeded];
          [self.tableView reloadData];
     }];
}

- (void)updateConstraints
{
    [super updateConstraints];

    [self.tableViewHeightConstraint deactivate];

    @weakify(self);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        self.tableViewHeightConstraint = make.height.equalTo(@([[self class] estimateTableViewHeight:self.viewModel]));
    }];
}

- (CGFloat)usernameTextWidth
{
    NSString *textToMeasure = self.viewModel.username;

    UIFont *font = self.usernameText.font;

    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;

    CGSize nickNameSize = [textToMeasure boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, MomentsUsernameTextHeight)
                                                     options:options
                                                  attributes:@{ NSFontAttributeName :font,NSParagraphStyleAttributeName :paragraphStyle }
                                                     context:nil].size;

    return nickNameSize.width;
}

+ (CGFloat)estimateTableViewHeight:(MomentsCellViewModel *)viewModel
{
    NSArray *comments = viewModel.comments;

    __block CGFloat height = 0;
    [comments enumerateObjectsUsingBlock:^(MomentsCommentCellViewModel *subViewModel, NSUInteger idx, BOOL *stop) {

        height += [subViewModel estimateHeight];
    }];

    return height == 0.f ? : height + 10.0;
}

#pragma mark - public methods

+ (CGFloat)estimateHeightWithViewModel:(MomentsCellViewModel *)viewModel
{
    return 0.f;
}

#pragma mark - event response

- (void)onImageTapped:(UIGestureRecognizer *)recognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onImageTapped:)])
    {
        [self.delegate onImageTapped:self.viewModel];
    }
}

- (void)onLabelTapped:(UIGestureRecognizer *)recognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onLabelTapped:)])
    {
        [self.delegate onLabelTapped:self.viewModel];
    }
}

#pragma mark - getters and setters

- (UIImageView *)avatarView
{
    if (!_avatarView)
    {
        _avatarView = [UIImageView new];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.userInteractionEnabled = YES;
        _avatarView.layer.cornerRadius = MomentsHeadImageSize / 2.0;
        _avatarView.layer.masksToBounds = YES;

        UITapGestureRecognizer *onTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageTapped:)];
        [_avatarView addGestureRecognizer:onTap];
    }

    return _avatarView;
}

- (UILabel *)usernameText
{
    if (!_usernameText)
    {
        _usernameText = [UILabel new];
        _usernameText.backgroundColor = [UIColor clearColor];
        _usernameText.textColor = [Utils HexColorToRedGreenBlue:@"#6b9aa2"];
        _usernameText.textAlignment = NSTextAlignmentLeft;
        _usernameText.font = [UIFont boldSystemFontOfSize:15.0];
        _usernameText.numberOfLines = 1;
        _usernameText.lineBreakMode = NSLineBreakByTruncatingTail;
        _usernameText.userInteractionEnabled = YES;

        UITapGestureRecognizer *onTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLabelTapped:)];
        [_usernameText addGestureRecognizer:onTap];
    }

    return _usernameText;
}

- (UILabel *)timeText
{
    if (!_timeText)
    {
        _timeText = [UILabel new];
        _timeText.backgroundColor = [UIColor clearColor];
        _timeText.textColor = [Utils HexColorToRedGreenBlue:@"#939393"];
        _timeText.textAlignment = NSTextAlignmentRight;
        _timeText.font = [UIFont systemFontOfSize:11.f];
        _timeText.numberOfLines = 1;
    }

    return _timeText;
}

- (UIButton *)commentButton
{
    if (!_commentButton)
    {
        _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentButton setBackgroundImage:[UIImage imageNamed:@"moments_comment"] forState:UIControlStateNormal];
        _commentButton.backgroundColor = [UIColor clearColor];
    }

    return _commentButton;
}

- (UIButton *)commentCoverButton
{
    if (!_commentCoverButton)
    {
        _commentCoverButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentCoverButton setBackgroundColor:[UIColor clearColor]];

        @weakify(self);
        [[_commentCoverButton rac_signalForControlEvents:UIControlEventTouchUpInside]
         subscribeNext:^(id x) {

             @strongify(self);
             if (self.delegate && [self.delegate respondsToSelector:@selector(onEvaluateButtonTapped:)])
             {
                 [self.delegate onEvaluateButtonTapped:self];
             }
         }];
    }

    return _commentCoverButton;
}

- (UIButton *)deleteButton
{
    if (!_deleteButton)
    {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[Utils HexColorToRedGreenBlue:@"#939393"] forState:UIControlStateNormal];
        [_deleteButton.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
        [_deleteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        _deleteButton.backgroundColor = [UIColor clearColor];

        @weakify(self);
        [[_deleteButton rac_signalForControlEvents:UIControlEventTouchUpInside]
         subscribeNext:^(id x) {

             @strongify(self);
             if (self.delegate && [self.delegate respondsToSelector:@selector(onDeleteButtonTapped:)])
             {
                 [self.delegate onDeleteButtonTapped:self.viewModel];
             }
         }];
    }

    return _deleteButton;
}

- (UIView *)bottomLine
{
    if (!_bottomLine)
    {
        _bottomLine = UIView.new;
        _bottomLine.backgroundColor = [Utils HexColorToRedGreenBlue:@"#e7e3e1"];
    }

    return _bottomLine;
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }

    return _tableView;
}

@end

#pragma mark - MomentsTextTableViewCell

@implementation MomentsTextTableViewCell

#pragma mark - override methods

- (void)configViews
{
    [super configViews];

    [self.contentView addSubview:self.topicText];
}

- (void)setupLayoutConstraint
{
    [super setupLayoutConstraint];

    [self.commentButtonTopConstraint deactivate];

    @weakify(self);
    [self.topicText mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.top.equalTo(self.usernameText.mas_bottom).with.offset(MomentsTopicTextTopMargin);
        make.left.equalTo(self.avatarView.mas_right).with.offset(MomentsHeadImageHorizontalMargin);
        make.right.equalTo(self.contentView.mas_right).with.offset(-18);
        self.contentLabelHeightConstraint = make.height.equalTo(@0);
    }];

    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        self.commentButtonTopConstraint = make.top.equalTo(self.topicText.mas_bottom).with.offset(MomentsCommentTopMargin);
    }];
}

- (void)setupActionBind
{
    [super setupActionBind];

    RACSignal *signal = RACObserve(self, viewModel.topic);

    RAC(self.topicText, text) = [signal
                                 map:^id(NSString *content) {

                                     return content;
                                 }];

    @weakify(self);
    [signal
     subscribeNext:^(NSString *content) {

         @strongify(self);

         [self setNeedsUpdateConstraints];
         [self updateConstraintsIfNeeded];
     }];
}

- (void)updateConstraints
{
    [super updateConstraints];

    [self.contentLabelHeightConstraint deactivate];

    @weakify(self);
    [self.topicText mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        self.contentLabelHeightConstraint = make.height.equalTo(@([[self class] getTopicHeightWithViewModel:self.viewModel]));
    }];
}

#pragma mark - public methods

+ (CGFloat)estimateHeightWithViewModel:(MomentsCellViewModel *)viewModel
{
    CGFloat height = MomentsUsernameTextTopMargin + MomentsUsernameTextHeight;
    height += (MomentsTopicTextTopMargin + [[self class] getTopicHeightWithViewModel:viewModel]);
    height += (MomentsCommentTopMargin + MomentsCommentButtonSize + MomentsHeadImageVerticalMargin);
    if (viewModel.hasComments)
    {
        height += ([[self class] estimateTableViewHeight:viewModel]);
        height += MomentsTableViewTopMargin;
    }

    return height;
}

#pragma mark - private methods

+ (CGFloat)getTopicHeightWithViewModel:(MomentsCellViewModel *)viewModel
{
    NSString *textToMeasure = viewModel.topic;

    UIFont *font = [UIFont systemFontOfSize:14.0f];

    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;

    CGSize contentSize = [textToMeasure boundingRectWithSize:CGSizeMake(kScreenWidth - (2 * MomentsHeadImageHorizontalMargin + MomentsHeadImageSize + 18.0), CGFLOAT_MAX)
                                                      options:options
                                                   attributes:@{ NSFontAttributeName :font,NSParagraphStyleAttributeName :paragraphStyle }
                                                      context:nil].size;

    return contentSize.height;
}

#pragma mark - getters and setters

- (UILabel *)topicText
{
    if (!_topicText)
    {
        _topicText = [UILabel new];
        _topicText.backgroundColor = [UIColor clearColor];
        _topicText.textColor = [Utils HexColorToRedGreenBlue:@"#404040"];
        _topicText.font = [UIFont systemFontOfSize:14.f];
    }

    return _topicText;
}

@end

#pragma mark - MomentsImageTableViewCell

@implementation MomentsImageTableViewCell

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel.photos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MomentsImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];

    cell.imageView.image = self.viewModel.photos[indexPath.row];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:0];

    for (int index = 0; index < self.viewModel.attachs.count; index++)
    {
        NSIndexPath *imageIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
        MomentsImageCollectionViewCell *cell = (MomentsImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:imageIndexPath];
        CGRect bounds = [cell convertRect:cell.imageView.frame toView:self.superview.window];

        NSString *url = self.viewModel.attachs[index];

        Photo *photo = [[Photo alloc] init];
        photo.url = [NSURL URLWithString:url];
        photo.originBounds = bounds;

        [photos addObject:photo];
    }

    // 2.显示相册
    PhotoBrowser *browser = [[PhotoBrowser alloc] initWithPhotos:photos];
    browser.currentPhotoIndex = indexPath.row;
    [browser show];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewModel.isSinglePhoto)
    {
        UIImage *image = self.viewModel.photos[indexPath.row];
        return [[self class] scaleImageSizeWithImage:image];
    }
    else
    {
        CGFloat collectionViewWidth = kScreenWidth - 2 * MomentsHeadImageHorizontalMargin - MomentsHeadImageSize - 30;
        CGFloat collectionItemSize = (collectionViewWidth - 20) / 3;

        return CGSizeMake(collectionItemSize, collectionItemSize);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return self.viewModel.isSinglePhoto ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, 0, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return self.viewModel.isSinglePhoto ? 0.0 : 5.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return self.viewModel.isSinglePhoto ? 0.0 : 5.0;
}

#pragma mark - override

- (void)updateConstraints
{
    [super updateConstraints];

    [self.collectionViewHeightConstraint deactivate];
    [self.collectionViewTopConstraint deactivate];

    @weakify(self);
    [self.imageCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);

        self.collectionViewHeightConstraint = make.height.equalTo(@([[self class]getCollectionViewHeightWithViewModel:self.viewModel]));
        if (self.viewModel.isValidTopic)
        {
            self.collectionViewTopConstraint = make.top.equalTo(self.topicText.mas_bottom).with.offset(MomentsTopicTextTopMargin);
        }
        else
        {
            self.collectionViewTopConstraint = make.top.equalTo(self.usernameText.mas_bottom).with.offset(MomentsTopicTextTopMargin);
        }
    }];
}

- (void)configViews
{
    [super configViews];

    [self.contentView addSubview:self.imageCollectionView];
}

- (void)setupLayoutConstraint
{
    [super setupLayoutConstraint];

    [self.commentButtonTopConstraint deactivate];

    @weakify(self);
    [self.imageCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        self.collectionViewTopConstraint = make.top.equalTo(self.usernameText.mas_bottom).with.offset(MomentsTopicTextTopMargin);
        make.left.equalTo(self.avatarView.mas_right).with.offset(MomentsHeadImageHorizontalMargin);
        make.right.equalTo(self.contentView.mas_right).with.offset(-30);
        self.collectionViewHeightConstraint = make.height.equalTo(@0);
    }];

    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        self.commentButtonTopConstraint = make.top.equalTo(self.imageCollectionView.mas_bottom).with.offset(MomentsCommentTopMargin + 5);
    }];
}

- (void)setupActionBind
{
    [super setupActionBind];

    @weakify(self);
    [[[RACObserve(self, viewModel.photos)
       filter:^BOOL(id value) {

           return value != nil;
       }]
      deliverOnMainThread]
     subscribeNext:^(id _) {

         @strongify(self);
         [self.imageCollectionView reloadData];
         [self setNeedsUpdateConstraints];
         [self updateConstraintsIfNeeded];
     }];

    [RACObserve(self, viewModel.topic)
     subscribeNext:^(id _) {

         @strongify(self);
         [self setNeedsUpdateConstraints];
         [self updateConstraintsIfNeeded];
     }];
}

#pragma mark - public methods

+ (CGFloat)estimateHeightWithViewModel:(MomentsCellViewModel *)viewModel
{
    CGFloat height = MomentsUsernameTextTopMargin + MomentsUsernameTextHeight;
    height += (MomentsCommentTopMargin + MomentsCommentButtonSize + MomentsHeadImageVerticalMargin + 5);
    height += ([[self class] getCollectionViewHeightWithViewModel:viewModel] + MomentsTopicTextTopMargin);
    if (viewModel.isValidTopic)
    {
        height += (MomentsTopicTextTopMargin + [[self class] getTopicHeightWithViewModel:viewModel]);
    }

    if (viewModel.hasComments)
    {
        height += ([[self class] estimateTableViewHeight:viewModel]);
        height += MomentsTableViewTopMargin;
    }

    return height;
}

#pragma mark - private methods

+ (CGSize)scaleImageSizeWithImage:(UIImage *)image
{
    //    CGFloat width = (kScreenWidth - 2 * MomentsHeadImageHorizontalMargin - MomentsHeadImageSize - 30) / 2.0;
    
    //    CGSize  imageSize = image.size;
    CGFloat imageWidth = 100.0;
    CGFloat imageHeight = 100.0;

    return CGSizeMake(imageWidth, imageHeight);
}

+ (CGFloat)getCollectionViewHeightWithViewModel:(MomentsCellViewModel *)viewModel
{
    CGFloat collectionViewWidth = kScreenWidth - 2 * MomentsHeadImageHorizontalMargin - MomentsHeadImageSize - 30;
    CGFloat collectionItemSize = (collectionViewWidth - 20) / 3;

    NSUInteger photoCount = viewModel.attachs.count;
    CGFloat height;
    if (photoCount <= 3)
    {
        if (viewModel.isSinglePhoto)
        {
            UIImage *image = [viewModel.attachs firstObject];
            height = [[self class] scaleImageSizeWithImage:image].height;
        }
        else
        {
            height = collectionItemSize;
        }
    }
    else if (photoCount > 3 && photoCount <= 6)
    {
        height = 2 * collectionItemSize + 5;
    }
    else
    {
        height = 3 * collectionItemSize + 10;
    }

    return height;
}

#pragma mark - getters and setters

- (UICollectionView *)imageCollectionView
{
    if (!_imageCollectionView)
    {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.headerReferenceSize = CGSizeZero;
        _imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _imageCollectionView.scrollEnabled = NO;
        _imageCollectionView.delegate = self;
        _imageCollectionView.dataSource = self;
        _imageCollectionView.backgroundColor = [UIColor clearColor];

        [_imageCollectionView registerClass:[MomentsImageCollectionViewCell class] forCellWithReuseIdentifier:collectionCellIdentifier];
    }

    return _imageCollectionView;
}

@end

#pragma mark - MomentsSharedTableViewCell

@implementation MomentsSharedTableViewCell

#pragma mark - override

- (void)configViews
{
    [super configViews];

    [self.contentView addSubview:self.shareText];
    [self.contentView addSubview:self.shareBackground];

    [self.shareBackground addSubview:self.shareAvatarView];
    [self.shareBackground addSubview:self.shareContents];
}

- (void)setupLayoutConstraint
{
    [super setupLayoutConstraint];

    [self.commentButtonTopConstraint deactivate];

    @weakify(self);
    [self.shareText mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.left.equalTo(self.usernameText.mas_right).with.offset(MomentsUsernameTextRightMargin);
        make.right.equalTo(self.contentView.mas_right).with.offset(MomentsHeadImageHorizontalMargin);
        make.height.equalTo(@(MomentsUsernameTextHeight));
        make.centerY.equalTo(self.usernameText.mas_centerY);
    }];

    [self.shareBackground mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        self.shareTopConstraint = make.top.equalTo(self.usernameText.mas_bottom).with.offset(MomentsSharedViewTopMargin);
        make.left.equalTo(self.avatarView.mas_right).with.offset(MomentsHeadImageHorizontalMargin);
        make.right.equalTo(self.contentView.mas_right).with.offset(-10);
        make.height.equalTo(@(MomentsSharedViewHeight));
    }];

    [self.shareAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.left.and.top.equalTo(self.shareBackground).with.offset(MomentsSharedViewPadding);
        make.width.and.height.equalTo(@(MomentsSharedImageSize));
    }];

    [self.shareContents mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.left.equalTo(self.shareAvatarView.mas_right).with.offset(7);
        make.right.equalTo(self.shareBackground.mas_right).with.offset(-10);
        make.top.equalTo(self.shareBackground.mas_top).with.offset(5);
        make.bottom.equalTo(self.shareBackground.mas_bottom).with.offset(-5);
    }];

    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        self.commentButtonTopConstraint = make.top.equalTo(self.shareBackground.mas_bottom).with.offset(MomentsCommentTopMargin + 5);
    }];
}

- (void)setupActionBind
{
    [super setupActionBind];

    RACSignal *contentSignal = RACObserve(self, viewModel.sharedContent);
    RACSignal *imageSignal = RACObserve(self, viewModel.sharedAvatarUrl);

    RAC(self.shareContents, text) = [contentSignal
                                     map:^id(NSString *content) {

                                         return content;
                                     }];

    @weakify(self);
    [imageSignal
     subscribeNext:^(NSString *url) {

         @strongify(self);
         [self.shareAvatarView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

         }];
     }];

    [[RACSignal
      merge:@[ contentSignal, imageSignal ]]
     subscribeCompleted:^{

         @strongify(self);
         [self setNeedsUpdateConstraints];
         [self updateConstraintsIfNeeded];
     }];
}

- (void)updateConstraints
{
    [super updateConstraints];

    [self.shareTopConstraint deactivate];

    @weakify(self);
    [self.shareBackground mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        if (self.viewModel.isValidTopic)
        {
            self.shareTopConstraint = make.top.equalTo(self.topicText.mas_bottom).with.offset(MomentsSharedViewTopMargin);
        }
        else
        {
            self.shareTopConstraint = make.top.equalTo(self.usernameText.mas_bottom).with.offset(MomentsSharedViewTopMargin);
        }
    }];
}

#pragma mark - public methods

+ (CGFloat)estimateHeightWithViewModel:(MomentsCellViewModel *)viewModel
{
    CGFloat height = MomentsUsernameTextTopMargin + MomentsUsernameTextHeight;
    height += (MomentsSharedViewHeight + MomentsSharedViewTopMargin);
    height += (MomentsCommentTopMargin + MomentsCommentButtonSize + MomentsHeadImageVerticalMargin + 5);
    if (viewModel.isValidTopic)
    {
        height += (MomentsTopicTextTopMargin + [[self class] getTopicHeightWithViewModel:viewModel]);
    }

    if (viewModel.hasComments)
    {
        height += ([[self class] estimateTableViewHeight:viewModel]);
        height += MomentsTableViewTopMargin;
    }

    return height;
}

#pragma mark - event response

- (void)onSharedTapped:(UIGestureRecognizer *)recognizer
{
    NSLog(@"onSharedTapped");
}

#pragma mark - getters and setters

- (UILabel *)shareText
{
    if (!_shareText)
    {
        _shareText = [UILabel new];
        _shareText.backgroundColor = [UIColor clearColor];
        _shareText.textColor = [Utils HexColorToRedGreenBlue:@"#504644"];
        _shareText.textAlignment = NSTextAlignmentLeft;
        _shareText.font = [UIFont systemFontOfSize:14.f];
        _shareText.numberOfLines = 1;
        _shareText.lineBreakMode = NSLineBreakByTruncatingTail;
        _shareText.text = @"分享了一个链接";
    }

    return _shareText;
}

- (UIView *)shareBackground
{
    if (!_shareBackground)
    {
        _shareBackground = [UIView new];
        _shareBackground.backgroundColor = [Utils HexColorToRedGreenBlue:@"#939393"];
    }

    return _shareBackground;
}

- (UIImageView *)shareAvatarView
{
    if (!_shareAvatarView)
    {
        _shareAvatarView = [UIImageView new];
        _shareAvatarView.contentMode = UIViewContentModeScaleAspectFill;
        _shareAvatarView.userInteractionEnabled = YES;
        _shareAvatarView.clipsToBounds = YES;

        UITapGestureRecognizer *onTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSharedTapped:)];
        [_shareAvatarView addGestureRecognizer:onTap];
    }

    return _shareAvatarView;
}

- (UILabel *)shareContents
{
    if (!_shareContents)
    {
        _shareContents = [UILabel new];
        _shareContents.backgroundColor = [UIColor clearColor];
        _shareContents.textColor = [Utils HexColorToRedGreenBlue:@"#504644"];
        _shareContents.textAlignment = NSTextAlignmentLeft;
        _shareContents.font = [UIFont systemFontOfSize:12.f];
        _shareContents.numberOfLines = 2;
        _shareContents.lineBreakMode = NSLineBreakByTruncatingTail;
        _shareContents.userInteractionEnabled = YES;

        UITapGestureRecognizer *onTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSharedTapped:)];
        [_shareContents addGestureRecognizer:onTap];
    }

    return _shareContents;
}

@end
