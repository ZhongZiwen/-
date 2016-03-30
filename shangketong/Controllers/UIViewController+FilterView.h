//
//  UIViewController+FilterView.h
//  shangketong
//
//  Created by sungoin-zbs on 16/1/26.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKTFilterView.h"
#import "IndexCondition.h"
#import "Filter.h"
#import "FilterValue.h"
#import "FilterCondition.h"

@interface UIViewController (FilterView)<SKTFilterViewDataSource, SKTFilterViewDelegate>

@property (strong, nonatomic) NSMutableArray *filterShowArray;    // 筛选显示
@property (strong, nonatomic) NSMutableArray *filterHiddenArray;  // 筛选不显示
@property (strong, nonatomic) NSMutableArray *conditionArray;     // 选中筛选
@property (strong, nonatomic) NSArray *sortArray;                 // 排序
@property (strong, nonatomic) NSArray *jsonArray;                 // 筛选条件
@property (strong, nonatomic) IndexCondition *curSort;            // 当前排序
@property (strong, nonatomic) SKTFilterView *filterView;

// 配置筛选视图缓存数据，以及必要的参数
- (void)configFilterWithTableName:(NSString *)tableName currentSortKey:(NSString *)sortKey;

// 收起筛选视图
- (void)hideFilterView;

// 获取筛选数据
- (void)sendRequestForFilter;
@end
