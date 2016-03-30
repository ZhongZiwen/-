//
//  PoolReturnViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PoolReturnType) {
    PoolReturnTypeLead = 0,
    PoolReturnTypeCustomer
};

@class Reason;

@interface PoolReturnViewController : UIViewController

@property (copy, nonatomic) NSString *groupId;      // 公海池id
@property (copy, nonatomic) NSString *name;         // 销售线索或客户名称
@property (copy, nonatomic) NSString *groupName;    // 公海池name
@property (strong, nonatomic) Reason *reason;
@property (assign, nonatomic) PoolReturnType poolReturnType;
@end
