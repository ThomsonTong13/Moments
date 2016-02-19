//
//  MomentsPublishViewController.m
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "MomentsPublishViewController.h"
#import "PhotoPickerViewController.h"

#import "MomentsPublishViewModel.h"
#import "PhotoAssets.h"
#import "PhotoUtils.h"

#import "MomentsPublishPictureCell.h"

#import "Photo.h"
#import "PhotoBrowser.h"

static NSString * const pictureCellIdentifier = @"pictureCell";
static NSString * const locationCellIdentifier = @"locationCell";
static NSString * const remindCellIdentifier = @"remindCell";

@interface MomentsPublishViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MomentsPublishPictureCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation MomentsPublishViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configViews];
    [self setupActionBinds];

    PhotoPickerViewController *picker = [[PhotoPickerViewController alloc] init];
    picker.viewModel = [self.viewModel pickerViewModelWithStatus:PhotoPickerViewShowStatusCameraRoll];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)dealloc
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        MomentsPublishPictureCell *cell = [tableView dequeueReusableCellWithIdentifier:pictureCellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        cell.viewModel = self.viewModel;

        return cell;
    }

    NSString *cellIdentifier = indexPath.section == 1 ? remindCellIdentifier: locationCellIdentifier;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            return [MomentsPublishPictureCell estimatedHeightWithViewModel:self.viewModel];
        }
    }

    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 20.0;
    }

    return .0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (!view)
    {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
        view.contentView.backgroundColor = tableView.backgroundColor;
    }

    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _placeholderLabel.hidden = YES;

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (!textView.text || textView.text.length <= 0)
    {
        _placeholderLabel.hidden = NO;
    }

    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.textView resignFirstResponder];
}

#pragma mark - MomentsPublishPictureCellDelegate

- (void)didSelectAddItem
{
    PhotoPickerViewController *picker = [[PhotoPickerViewController alloc] init];
    picker.viewModel = [self.viewModel pickerViewModelWithStatus:PhotoPickerViewShowStatusCameraRoll];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Event Response

- (void)backCurrentView:(id)sender
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil
                                                                     message:@"退出此次编辑?"
                                                              preferredStyle:UIAlertControllerStyleAlert];

    [alertVc addAction:[UIAlertAction actionWithTitle:@"取消"
                                                style:UIAlertActionStyleCancel
                                              handler:nil]];

    @weakify(self);
    [alertVc addAction:[UIAlertAction actionWithTitle:@"确定"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {

                                                  @strongify(self);
                                                  [self.navigationController popViewControllerAnimated:YES];
                                              }]];

    [self presentViewController:alertVc
                       animated:YES
                     completion:nil];
}

- (void)onRightButton:(id)sender
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];

    [self.navigationController popViewControllerAnimated:YES];

    NSLog(@"%@", self.viewModel.textPlain);
    NSLog(@"%@", self.viewModel.assets);
}

#pragma mark - Private Methods

- (void)configViews
{
    [self createPopButton];
    [self createRightButton];

    self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)setupActionBinds
{
    RAC(self.viewModel, textPlain) = self.textView.rac_textSignal;
    RAC(self.placeholderLabel, hidden) = [self.textView.rac_textSignal
                                          map:^id(NSString *text) {

                                              return @(text && text.length > 0);
                                          }];

    @weakify(self);
    [[[[NSNotificationCenter defaultCenter]
        rac_addObserverForName:PhotoPickerPhotoTakeDoneNotification
        object:nil]
        deliverOnMainThread]
        subscribeNext:^(NSNotification *notification) {

            @strongify(self);

            NSArray *selectedAssets = notification.object;

            self.viewModel.assets = [[NSArray alloc] initWithArray:selectedAssets];
            [self.tableView reloadData];
        }];
}

- (void)createPopButton
{
    UIButton *popButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [popButton setFrame:CGRectMake(0, 0, 44.0, 44.0)];
    [popButton addTarget:self action:@selector(backCurrentView:) forControlEvents:UIControlEventTouchUpInside];
    [popButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [popButton setImageEdgeInsets:UIEdgeInsetsMake(0, -22.0, 0, 0)];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:popButton];
}

- (void)createRightButton
{
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    sendButton.frame = CGRectMake(0, 0, 44.0, 44.0);
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[Utils HexColorToRedGreenBlue:@"#FFFFFF"] forState:UIControlStateNormal];
    [sendButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15.0]];
    [sendButton setBackgroundColor:[UIColor clearColor]];
    [sendButton setContentEdgeInsets:UIEdgeInsetsMake(7.0, 0, 7.0, 0)];
    [sendButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [sendButton addTarget:self action:@selector(onRightButton:) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
}

#pragma mark - Getters and Setters

- (UIView *)tableHeaderView
{
    if (!_tableHeaderView)
    {
        _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 110.0)];
        _tableHeaderView.backgroundColor = [UIColor whiteColor];

        [_tableHeaderView addSubview:self.textView];
        [_tableHeaderView addSubview:self.placeholderLabel];

        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.edges.equalTo(_tableHeaderView).with.insets(UIEdgeInsetsMake(0, 15.0, 5.0, 0));
        }];

        [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.equalTo(_tableHeaderView.mas_left).with.offset(20);
            make.top.equalTo(_tableHeaderView.mas_top).with.offset(7);
        }];
    }

    return _tableHeaderView;
}

- (UITextView *)textView
{
    if (!_textView)
    {
        _textView = [UITextView new];
        _textView.showsHorizontalScrollIndicator = NO;
        _textView.showsVerticalScrollIndicator = YES;
        _textView.delegate = self;
        _textView.textColor = [UIColor blackColor];
        [_textView setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15.0]];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.scrollEnabled = YES;
        _textView.bounces = YES;
        _textView.editable = YES;
        _textView.selectable = YES;
    }

    return _textView;
}

- (UILabel *)placeholderLabel
{
    if (!_placeholderLabel)
    {
        _placeholderLabel = [UILabel new];
        _placeholderLabel.textColor = [Utils HexColorToRedGreenBlue:@"#c9c9c9"];
        [_placeholderLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15.0]];
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.text = @"这一刻的想法...";
        _placeholderLabel.hidden = NO;
    }

    return _placeholderLabel;
}

@end
