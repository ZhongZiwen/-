//
//  TableHeaderView.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableHeaderView : UIView

/** 仪表盘类型 */
@property (nonatomic, assign) NSInteger chartType;

/** 时间类型 */
@property (nonatomic, copy) NSString *periodType;

/** 仪表名称 */
@property (nonatomic, copy) NSString *chartName;

/** 图表数据源 */
@property (nonatomic, copy) NSString *sourceData;

/** 仪表信息描述 */
@property (nonatomic, strong) NSArray *chartConditions;

@property (nonatomic, copy) void(^infoButtonBlock)(void);

@end
