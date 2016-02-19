//
//  PhotoPickerCollectionView.m
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "PhotoPickerCollectionView.h"
#import "PhotoPickerCollectionViewViewModel.h"
#import "PhotoPickerCollectionViewCell.h"

#import "PhotoAssets.h"

#import "ReactiveCocoa.h"

@interface PhotoPickerCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate>
@end

@implementation PhotoPickerCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithFrame:frame collectionViewLayout:layout])
    {
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;

        [self setupActionBinds];
    }

    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewModel.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    PhotoPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    PhotoAssets *assets = self.viewModel.assets[indexPath.row];
    cell.pickerImageView.image = assets.thumbImage;
    cell.pickerImageView.maskViewFlag = [self.viewModel photoIsSelected:assets];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoPickerCollectionViewCell *cell = (PhotoPickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    PhotoAssets *assets = self.viewModel.assets[indexPath.row];
    if ([self.viewModel photoIsSelected:assets])
    {
        [self.viewModel removeSelectedAssets:assets];
    }
    else
    {
        NSUInteger maxCount = (self.viewModel.maxCount < 0) ? 9: self.viewModel.maxCount;
        if (self.viewModel.selectAssets.count >= maxCount)
        {
            NSString *format = [NSString stringWithFormat:@"最多只能选择%zd张图片", maxCount];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒"
                                                                message:format
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"好的", nil];
            [alertView show];

            return ;
        }

        [self.viewModel addSelectedAssets:assets];
    }

    cell.pickerImageView.maskViewFlag = [self.viewModel photoIsSelected:assets];
}

#pragma mark - private methods

- (void)setupActionBinds
{
    @weakify(self);
    [[RACObserve(self, viewModel.assets)
      filter:^BOOL(id value) {

          return value != nil;
      }]
      subscribeNext:^(NSArray *assets) {

          @strongify(self);
          [self reloadData];

          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

              CGFloat pointY = MAX(self.contentSize.height - self.frame.size.height, 0.f);
              [self setContentOffset:CGPointMake(.0f, pointY)];
          });
      }];
}

@end
