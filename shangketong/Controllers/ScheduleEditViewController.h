//
//  ScheduleEditViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"
#import <XLFormRowDescriptor.h>

@interface ScheduleEditViewController : XLFormViewController

@property (nonatomic, strong) XLFormRowDescriptor *rowDescriptor;
@property (nonatomic, strong) NSMutableDictionary *scheduleSourceDict;
@property (nonatomic, copy) void(^valueBlock)(NSDictionary *dict);
@end
