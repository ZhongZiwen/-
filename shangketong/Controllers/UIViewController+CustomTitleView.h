//
//  UIViewController+CustomTitleView.h
//  shangketong
//
//  Created by sungoin-zbs on 16/1/27.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTitleView.h"
#import "IndexCondition.h"

@interface UIViewController (CustomTitleView)

@property (strong, nonatomic) CustomTitleView *titleView;   // 索引视图
@property (strong, nonatomic) NSMutableArray *indexArray;
@property (strong, nonatomic) IndexCondition *curIndex;     // 当前选中索引

// 配置索引视图缓存数据
- (void)configTitleViewWithTableName:(NSString *)tableName currentIndexKey:(NSString *)indexKey;

// 获取索引数据
- (void)sendRequestForIndex;
// 刷新索引
- (void)sendRequestRefreshForIndex;
@end
