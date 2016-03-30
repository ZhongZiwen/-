//
//  LeadListViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeadListViewController : UIViewController

@property (strong, nonatomic) NSNumber *activityId;
@property (copy, nonatomic) void(^refreshBlock)(void);

// 删除销售线索，并刷新索引、列表
- (void)deleteAndRefreshDataSource;
@end
