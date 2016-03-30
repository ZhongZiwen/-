//
//  CustomerViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"
#import "UIViewController+CustomTitleView.h"
#import "UIViewController+FilterView.h"

@interface CustomerViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;

- (void)sendRequestInit;
- (void)sendRequest;

// 删除销售线索，并刷新索引、列表
- (void)deleteAndRefreshDataSource;
@end
