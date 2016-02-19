//
//  MomentsViewController.m
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "MomentsViewController.h"
#import "MomentsPublishViewController.h"

#import "MomentsViewModel.h"
#import "MomentsCellViewModel.h"
#import "MomentsCommentCellViewModel.h"

#import "MomentsHeaderView.h"
#import "MomentsBaseTableViewCell.h"

static CGFloat kTableHeaderHeight = 220;

@interface MomentsViewController () <MomentsCellDelegate, MomentsHeaderViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MomentsHeaderView *headerView;

@property (nonatomic, strong) MomentsViewModel *viewModel;
@property (nonatomic, strong) MomentsCellViewModel *deleteViewModel;

@end

@implementation MomentsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configViews];

    [self loadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoMomentsPublish"])
    {
        MomentsPublishViewController *publishVc = segue.destinationViewController;
        publishVc.viewModel = [self.viewModel publishViewModel];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel.momentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MomentsCellViewModel *viewModel = self.viewModel.momentList[indexPath.row];

    NSString *cellIdentifier = [viewModel identifier];

    MomentsBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [viewModel cellWithIdentifier:cellIdentifier];
        cell.delegate = self;
    }

    cell.viewModel = viewModel;

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MomentsCellViewModel *viewModel = self.viewModel.momentList[indexPath.row];

    CGFloat height = [viewModel estimateHeight];

    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MomentsCellViewModel *viewModel = self.viewModel.momentList[indexPath.row];

    CGFloat height = [viewModel estimateHeight];

    return height;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView)
    {
        // pass the current offset of the UITableView so that the ParallaxHeaderView layouts the subViews.
        [(MomentsHeaderView *)self.tableView.tableHeaderView layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
    }
}

#pragma mark - MomentsHeaderViewDelegate

- (void)onAvatarTapped:(id)object
{
    NSLog(@"点击头像");
}

#pragma mark - MomentsCellDelegate

- (void)onImageTapped:(MomentsCellViewModel *)viewModel
{
    NSLog(@"点击头像");
}

- (void)onLabelTapped:(MomentsCellViewModel *)viewModel
{
    NSLog(@"点击Username");
}

- (void)onEvaluateButtonTapped:(MomentsBaseTableViewCell *)cell
{
    NSLog(@"点击评论");
}

- (void)onReplyTapped:(MomentsBaseTableViewCell *)cell viewModel:(MomentsCommentCellViewModel *)viewModel
{
    NSLog(@"回复评论");
}

- (void)onDeleteButtonTapped:(MomentsCellViewModel *)viewModel
{
    self.deleteViewModel = viewModel;

    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:@"是否要删除这条动态" preferredStyle:UIAlertControllerStyleAlert];

    @weakify(self);
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"删除"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {

                                                        [[[self.viewModel removeMoments:self.deleteViewModel.momentID]
                                                           deliverOnMainThread]
                                                           subscribeNext:^(NSString *result) {

                                                               @strongify(self);

                                                               if ([result isEqualToString:@"Succeed"])
                                                               {
                                                                   [self.tableView reloadData];
                                                               }
                                                           }];
                                                    }];

    [alertVc addAction:action1];
    [alertVc addAction:action2];

    [self presentViewController:alertVc
                       animated:YES
                     completion:nil];
}

#pragma mark - Event Response

- (void)onPublishButton:(id)sender
{
    [self performSegueWithIdentifier:@"gotoMomentsPublish" sender:self];
}

#pragma mark - Private Methods

- (void)configViews
{
    [self.navigationItem setTitle:@"朋友圈"];
    [self createRightButton];

    _headerView = [[MomentsHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTableHeaderHeight)];
    _headerView.delegate = self;
    _tableView.tableHeaderView = _headerView;

    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)createRightButton
{
    UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [publishButton setFrame:CGRectMake(0, 0, 44.0, 44.0)];
    [publishButton setImage:[UIImage imageNamed:@"moments_publish"] forState:UIControlStateNormal];
    [publishButton setImageEdgeInsets:UIEdgeInsetsMake(11.0, 0, 11.0, -22.0)];
    [publishButton setBackgroundColor:[UIColor clearColor]];
    [publishButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [publishButton addTarget:self action:@selector(onPublishButton:) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:publishButton];
}

- (void)loadData
{
    @weakify(self);
    [[[self.viewModel loadNextPage]
       deliverOnMainThread]
       subscribeNext:^(id x) {

           @strongify(self);
           self.headerView.viewModel = self.viewModel;
           [self.tableView reloadData];
       }];
}

#pragma mark - Getters & Setters

- (MomentsViewModel *)viewModel
{
    if (!_viewModel)
    {
        _viewModel = [[MomentsViewModel alloc] init];
    }

    return _viewModel;
}

@end
