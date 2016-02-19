//
//  PhotoPickerAssetsViewController.m
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "PhotoPickerAssetsViewController.h"
#import "PhotoPickerViewModel.h"
#import "PhotoAssets.h"

#import "PhotoPickerCollectionView.h"
#import "PhotoPickerCollectionViewCell.h"

#import "PhotoUtils.h"
#import "ReactiveCocoa.h"
#import "Masonry.h"

static NSString * const cellIdentifier = @"cellIdentifier";

@interface PhotoPickerAssetsViewController ()

@property (nonatomic, strong) PhotoPickerCollectionView *collectionView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIButton *tickView;

@end

@implementation PhotoPickerAssetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configDatas];
    [self configViews];
    [self setupLayoutConstraints];
    [self setupActionBinds];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - event response

- (void)pop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoPickerPhotoTakeDoneNotification object:self.viewModel.selectAssets];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods

- (void)configDatas
{
    [self.viewModel fetchAssets];
}

- (void)configViews
{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.backgroundColor = [UIColor clearColor];
    cancelButton.frame = CGRectMake(14.0, 0, 30.0, 44.0);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [cancelButton setContentEdgeInsets:UIEdgeInsetsMake(7.0, 0, 7.0, 0)];

    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.0];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 44.0, 44.0)];
    [backButton addTarget:self action:@selector(pop:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(7.0, -22.0, 7.0, 0)];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.opaque = NO;
    titleLabel.enabled = YES;
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.text = self.viewModel.assetsGroup.groupName;

    self.navigationItem.titleView = titleLabel;

    [self.view addSubview:self.toolBar];
    [self.view addSubview:self.collectionView];

    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setupLayoutConstraints
{
    @weakify(self);
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-44);
        make.top.equalTo(self.view.mas_top).with.offset(64.0);
    }];

    [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.equalTo(@44);
    }];
}

- (void)setupActionBinds
{
    @weakify(self);
    [RACObserve(self.viewModel, selectAssets)
     subscribeNext:^(NSArray *selectAssets) {

         @strongify(self);
         NSUInteger count = selectAssets.count;
         self.doneButton.enabled = count > 0;
         self.tickView.hidden = count == 0;
         [self.tickView setTitle:[NSString stringWithFormat:@"%zi", count]
                        forState:UIControlStateNormal];
     }];
}

#pragma mark - getters and setters

- (UIToolbar *)toolBar
{
    if (!_toolBar)
    {
        _toolBar = [[UIToolbar alloc] init];
        _toolBar.translatesAutoresizingMaskIntoConstraints = NO;

        UIBarButtonItem *fiexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneButton];

        _toolBar.items = @[ fiexItem, rightItem ];
    }

    return _toolBar;
}

- (UIButton *)doneButton
{
    if (!_doneButton)
    {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setTitleColor:[PhotoUtils HexColorToRedGreenBlue:@"#fb9c41"]
                          forState:UIControlStateNormal];
        [_doneButton setTitleColor:[PhotoUtils HexColorToRedGreenBlue:@"#c9c9c9"]
                          forState:UIControlStateDisabled];
        _doneButton.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.0];
        _doneButton.frame = CGRectMake(0, 0, 45, 45);
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        [_doneButton addSubview:self.tickView];
    }

    return _doneButton;
}

- (UIButton *)tickView
{
    if (!_tickView)
    {
        _tickView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tickView setTitleColor:[UIColor whiteColor]
                        forState:UIControlStateNormal];
        [_tickView.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:15.0]];
        [_tickView setBackgroundColor:[UIColor clearColor]];
        [_tickView setBackgroundImage:[UIImage imageNamed:@"photo_picker_count_background"]
                             forState:UIControlStateNormal];
        _tickView.frame = CGRectMake(-20, 12, 20, 20);
        _tickView.hidden = YES;
    }

    return _tickView;
}

- (PhotoPickerCollectionView *)collectionView
{
    if (!_collectionView)
    {
        CGFloat size = (self.view.frame.size.width - 2.0 * 4 + 1) / 4;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(size, size);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 2.0;
        flowLayout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, 2.0);

        _collectionView = [[PhotoPickerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.viewModel = self.viewModel.collectionViewViewModel;
        [_collectionView registerClass:[PhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    }

    return _collectionView;
}

@end
