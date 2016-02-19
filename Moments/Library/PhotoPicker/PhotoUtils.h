//
//  PhotoUtils.h
//  PhotoPicker
//
//  Created by Thomson on 15/12/1.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define PhotoPickerPhotoTakeDoneNotification @"PhotoPickerPhotoTakeDoneNotification"

@interface PhotoUtils : NSObject

+ (UIColor *) HexColorToRedGreenBlue:(NSString *)hexColorString;

@end
