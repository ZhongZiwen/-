//
//  PoolViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@class PoolGroup;

typedef NS_ENUM(NSInteger, PoolType) {
    PoolTypeLead = 0,
    PoolTypeCustomer
};

@interface PoolViewController : BaseViewController

@property (assign, nonatomic) PoolType poolType;
@property (copy, nonatomic) void(^poolGroupNameBlock) (PoolGroup*);
@end
