//
//  PhotoPickerGroupViewController.m
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "PhotoPickerGroupViewController.h"
#import "PhotoPickerAssetsViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "ReactiveCocoa.h"

#import "PhotoPickerGroupCell.h"
#import "PhotoPickerViewModel.h"
#import "PhotoPickerGroupCellViewModel.h"

static NSString * const groupCellIdentifier = @"groupCellIdentifier";

@interface PhotoPickerGroupViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UIImageView *_lockImageView;
    UILabel     *_lockLabel;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PhotoPickerGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configViews];

    [self setupActionBinds];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoPickerGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:groupCellIdentifier forIndexPath:indexPath];
    cell.viewModel = self.viewModel.groups[indexPath.row];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PhotoPickerGroupCellViewModel *viewModel = self.viewModel.groups[indexPath.row];
    PhotoPickerAssetsViewController *assetsVc = [[PhotoPickerAssetsViewController alloc] init];
    self.viewModel.assetsGroup = viewModel.group;
    assetsVc.viewModel = self.viewModel;

    [self.navigationController pushViewController:assetsVc animated:YES];
}

#pragma mark - event response

- (void)onRightButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods

- (void)configViews
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.opaque = NO;
    titleLabel.enabled = YES;
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.text = @"选择相册";

    self.navigationItem.titleView = titleLabel;

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.backgroundColor = [UIColor clearColor];
    closeButton.frame = CGRectMake(0, 0, 44.0, 44.0);
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [closeButton setContentEdgeInsets:UIEdgeInsetsMake(7.0, 0, 7.0, 0)];
    [closeButton addTarget:self action:@selector(onRightButton:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.0];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];

    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted ||
        author == ALAuthorizationStatusDenied)
    {
        [self showLockTip];
    }
    else
    {
        [self.view addSubview:self.tableView];

        @weakify(self);
        [self.viewModel fetchGroupsWithCompletionBlock:^{

            @strongify(self);
            PhotoPickerGroup *pickerGroup = nil;
            for (PhotoPickerGroupCellViewModel *viewModel in self.viewModel.groups)
            {
                PhotoPickerGroup *group = viewModel.group;
                if ((self.viewModel.status == PhotoPickerViewShowStatusCameraRoll ||
                     self.viewModel.status == PhotoPickerViewShowStatusVideo) &&
                    ([group.groupName isEqualToString:@"Camera Roll"] ||
                     [group.groupName isEqualToString:@"相机胶卷"]))
                {
                    pickerGroup = group;
                    break;
                }
                else if (self.viewModel.status == PhotoPickerViewShowStatusSavePhotos &&
                         ([group.groupName isEqualToString:@"Saved Photos"] ||
                          [group.groupName isEqualToString:@"保存相册"]))
                {
                    pickerGroup = group;
                    break;
                }
                else if (self.viewModel.status == PhotoPickerViewShowStatusPhotoStream &&
                         ([group.groupName isEqualToString:@"Stream"] ||
                          [group.groupName isEqualToString:@"我的照片流"]))
                {
                    pickerGroup = group;
                    break;
                }
                else if (self.viewModel.status == PhotoPickerViewShowStatusAllPhoto &&
                         ([group.groupName isEqualToString:@"All Photos"] ||
                          [group.groupName isEqualToString:@"所有照片"]))
                {
                    pickerGroup = group;
                    break;
                }
            }

            if (!pickerGroup) return ;

            PhotoPickerAssetsViewController *assetsVc = [[PhotoPickerAssetsViewController alloc] init];
            self.viewModel.assetsGroup = pickerGroup;
            assetsVc.viewModel = self.viewModel;

            [self.navigationController pushViewController:assetsVc animated:NO];
        }];
    }
}

- (void)setupActionBinds
{
    @weakify(self);
    [RACObserve(self.viewModel, groups)
     subscribeNext:^(id x) {

         @strongify(self);
         [self.tableView reloadData];
     }];
}

/**
 *  Display empty tip
 */
- (void)showLockTip
{
    if(_lockLabel || _lockImageView) return;

    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 200);

    _lockImageView = [[UIImageView alloc] init];
    _lockImageView.image = [UIImage imageNamed:@"lock"];
    _lockImageView.frame = frame;
    _lockImageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:_lockImageView];

    frame = CGRectMake(20, 0, self.view.frame.size.width - 40, self.view.frame.size.height);

    _lockLabel = [[UILabel alloc] initWithFrame:frame];
    _lockLabel.text = @"您屏蔽了选择相册的权限，开启请去系统设置->隐私->我的App来打开权限";
    _lockLabel.textColor = [UIColor blackColor];
    _lockLabel.textAlignment = NSTextAlignmentCenter;
    _lockLabel.backgroundColor = [UIColor clearColor];
    _lockLabel.numberOfLines = 0;
    [self.view addSubview:_lockLabel];
}

/**
 *  Remove empty tip
 */
- (void)hideLockTip
{
    if (_lockLabel)
    {
        [_lockLabel removeFromSuperview];

        _lockLabel = nil;
    }

    if (_lockImageView)
    {
        [_lockImageView removeFromSuperview];

        _lockImageView = nil;
    }
}

#pragma mark - getters and setters

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PhotoPickerGroupCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:groupCellIdentifier];
    }

    return _tableView;
}

@end
