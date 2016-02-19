//
//  Utils.h
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth  ([UIScreen mainScreen].bounds.size.width)

@interface Utils : NSObject

+ (UIColor *)HexColorToRedGreenBlue:(NSString *)hexColorString;

+ (NSString *)timeWithDate:(NSDate *)date;

@end
