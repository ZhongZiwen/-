//
//  ContactViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"
#import "UIViewController+CustomTitleView.h"
#import "UIViewController+FilterView.h"

@interface ContactViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;

// 初始化
- (void)sendRequestInit;
- (void)sendRequest;

// 删除联系人，并刷新索引、列表
- (void)deleteAndRefreshDataSource;
@end
