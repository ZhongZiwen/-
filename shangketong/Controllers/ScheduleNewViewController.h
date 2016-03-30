//
//  ScheduleNewViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"

@interface ScheduleNewViewController : XLFormViewController

///所选日期
@property (copy, nonatomic) NSString *dateString;
///默认当前参与人id
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *userIcon;
@property (nonatomic, strong) NSString *userName;

@property (copy, nonatomic) void(^refreshBlock)(void);
@end
