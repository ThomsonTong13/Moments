//
//  PhotoPickerCollectionView.h
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoPickerCollectionViewViewModel;

@interface PhotoPickerCollectionView : UICollectionView

@property (nonatomic, strong) PhotoPickerCollectionViewViewModel *viewModel;

@end
