//
//  OpportunityViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"
#import "UIViewController+FilterView.h"
#import "UIViewController+CustomTitleView.h"

@interface OpportunityViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;

@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UILabel *bottomLabel;
@property (assign, nonatomic) BOOL isStageList;

// 初始化
- (void)sendRequestInit;
// 获取销售阶段
- (void)sendRequestForOpportunityStageList;
// 获取销售机会列表
- (void)sendRequestForOpportunityList;
// 获取某个阶段下的销售机会列表
- (void)openSectionWithStageIndex:(NSInteger)index;
// 关闭指定的section
- (void)closeSectionWithStageIndex:(NSInteger)index;
- (void)deleteAndRefreshDataSource;
@end
