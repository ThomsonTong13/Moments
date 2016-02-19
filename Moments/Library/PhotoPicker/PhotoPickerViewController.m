//
//  PhotoPickerViewController.m
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "PhotoPickerViewController.h"
#import "PhotoPickerGroupViewController.h"

@interface PhotoPickerViewController ()
@property (nonatomic, weak) PhotoPickerGroupViewController *groupViewController;
@end

@implementation PhotoPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods

- (void)configViews
{
    PhotoPickerGroupViewController *groupViewController = [[PhotoPickerGroupViewController alloc] init];
    groupViewController.viewModel = self.viewModel;

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:groupViewController];
    nav.view.frame = self.view.bounds;
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];

    self.groupViewController = groupViewController;

    self.view.backgroundColor = [UIColor whiteColor];
}

@end
