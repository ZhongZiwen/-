//
//  TodayPlanLaterController.h
//  shangketong
//
//  Created by 蒋 on 15/12/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <XLForm/XLForm.h>

@interface TodayPlanLaterController : XLFormViewController
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *endDate;

@property (nonatomic, copy) void(^CommitLaterTimeBlock)(NSString *startString, NSString *endString);
@end
