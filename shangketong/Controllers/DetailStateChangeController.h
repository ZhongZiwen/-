//
//  DetailStateChangeController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ValueIdModel;

typedef NS_ENUM(NSInteger, DetailStateChangeType) {
    DetailStateChangeTypeActivity,          // 市场活动
    DetailStateChangeTypeSaleLeads          // 销售线索
};

@interface DetailStateChangeController : UIViewController

@property (strong, nonatomic) ValueIdModel *currentState;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (assign, nonatomic) DetailStateChangeType changeType;
@property (copy, nonatomic) void(^refreshBlock)(ValueIdModel *item);
@end
