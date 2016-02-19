//
//  MomentsPublishViewModel.h
//  Moments
//
//  Created by Thomson on 16/2/18.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoPickerViewModel.h"

@interface MomentsPublishViewModel : NSObject

@property (nonatomic, strong) NSArray *assets;
@property (nonatomic, copy) NSString *textPlain;

- (RACSignal *)publish;
- (RACSignal *)publishContent;

- (PhotoPickerViewModel *)pickerViewModelWithStatus:(PhotoPickerViewShowStatus)status;

@end
