//
//  SKTDropDownMenu.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKTIndexPath.h"

@class SKTDropDownMenu, SKTFilter, SKTFilterValue, SKTCondition;

@protocol SKTDropDownMenuDelegate <NSObject>

@required
/**
 * 导航栏菜单视图
 * 点击某行
 */
- (void)menu:(SKTDropDownMenu*)menu smartViewDidSelectRowAtRow:(NSInteger)row;

@optional
/**
 * 点击是哪个type的第row 或者item项
 */
- (void)menu:(SKTDropDownMenu*)menu didSelectRowAtIndexPath:(SKTIndexPath*)indexPath;

/**
 * 判断leftTableView的行是否有已选条件
 */
- (BOOL)menu:(SKTDropDownMenu*)menu isConditionInRow:(NSInteger)row;

/**
 * 获取rightTableView row的类型
 */
- (NSInteger)menu:(SKTDropDownMenu*)menu searchTypeForItemInRow:(NSInteger)row;

/**
 * 取消选中条件
 */
- (void)menu:(SKTDropDownMenu*)menu deleteConditionWithItem:(SKTCondition*)condition;

/**
 * 重置条件
 */
- (void)resetCondition;

/**
 * 确定筛选条件
 */
- (void)confirmCondition;

/**
 * 点击筛选按钮
 */
- (void)didSelectAction;
/**
 * 自动收起筛选试图的时候，获取最新数据
 */
- (void)afreshGetDataSourceFromServer;
@end

@protocol SKTDropDownMenuDataSource <NSObject>

@optional
/**
 * 返回cell的高度，默认为44.0f
 */
- (CGFloat)menu:(SKTDropDownMenu*)menu heightForRowIndexPath:(SKTIndexPath*)indexPath;

/**
 * 点击筛选中leftTableView的row，对应二级列表的item数（item可以看作是二级列表的row）。返回值如果 >0，说明有二级列表，＝0，说明没有二级列表
 */
- (NSInteger)menu:(SKTDropDownMenu*)menu numberOfItemsInRow:(NSInteger)row;

/**
 * 点击筛选中二级列表的item，返回相应数据模型
 */
- (SKTFilterValue*)menu:(SKTDropDownMenu*)menu sourceForItemInRowAtIndexPath:(SKTIndexPath*)indexPath;

@required
/**
 * 返回一级列表的行数
 */
- (NSInteger)menu:(SKTDropDownMenu*)menu numberOfRowsInType:(SKTIndexPathType)type;

/**
 * 返回一级列表对应row的title
 */
- (NSString*)menu:(SKTDropDownMenu*)menu titleForRowAtIndexPath:(SKTIndexPath*)indexPath;

@end

@interface SKTDropDownMenu : UIView

@property (nonatomic, strong) NSMutableArray *conditionArray;
@property (nonatomic, weak) id<SKTDropDownMenuDelegate>delegate;
@property (nonatomic, weak) id<SKTDropDownMenuDataSource>dataSource;
@property (nonatomic, assign) NSInteger selectRow;
@property (nonatomic, assign) NSInteger smartViewSelectRow;
@property (nonatomic, assign) NSInteger searchType;                 // screeningRightTableView的类型 0:单选 1:多选 3:可添加类型

- (instancetype)initWithFrame:(CGRect)frame andViewController:(UIViewController*)controller;
- (void)backgroundTap;
- (void)reloadTableView;
@end
