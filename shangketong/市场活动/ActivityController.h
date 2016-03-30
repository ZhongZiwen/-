//
//  ActivityController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"
#import "UIViewController+FilterView.h"

@interface ActivityController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;

// 初始化
- (void)sendRequestInit;
- (void)sendRequest;

// 删除销售线索，并刷新索引、列表
- (void)deleteAndRefreshDataSource;
@end
