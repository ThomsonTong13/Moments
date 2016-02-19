//
//  PhotoPickerGroupCell.m
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "PhotoPickerGroupCell.h"
#import "PhotoPickerGroupCellViewModel.h"
#import "PhotoPickerGroup.h"
#import "ReactiveCocoa.h"

@interface PhotoPickerGroupCell ()

@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupPictureCountLabel;

@end

@implementation PhotoPickerGroupCell

- (void)awakeFromNib
{
    @weakify(self);
    [[RACObserve(self, viewModel.group)
      filter:^BOOL(id value) {

          return value != nil;
      }]
      subscribeNext:^(PhotoPickerGroup *group) {

          @strongify(self);
          self.groupNameLabel.text = group.groupName;
          self.groupImageView.image = group.thumbImage;
          self.groupPictureCountLabel.text = [NSString stringWithFormat:@"(%zi)",group.assetsCount];
      }];
}

@end
