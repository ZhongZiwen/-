//
//  CustomerListController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerListController : UIViewController

@property (strong, nonatomic) NSNumber *activityId;
@property (copy, nonatomic) void(^refreshBlock)(void);

// 删除客户
- (void)deleteAndRefreshDataSource;
@end
