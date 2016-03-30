//
//  SKTFilterView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterIndexPath.h"

@class SKTFilterView, Filter, FilterValue, IndexCondition, FilterCondition;

@protocol SKTFilterViewDataSource <NSObject>

@required
/** 获取当前排序*/
- (IndexCondition*)currentSortWithFilterView:(SKTFilterView*)filterView;

/** 获取筛选条件*/
- (NSArray*)conditionArrayWithFilterView:(SKTFilterView*)filterView;

@optional
/** 返回顺序列表和一级列表的行数*/
- (NSInteger)filterView:(SKTFilterView*)filterView numberOfRowsInType:(FilterType)type;

/** 返回二级列表的行数*/
- (NSInteger)filterView:(SKTFilterView*)filterView numberOfItemsInRow:(NSInteger)row;

/** 返回一级列表对应row的title  或者  返回一级列表选中行的FilterValue*/
- (id)filterView:(SKTFilterView*)filterView sourceForRowAtIndexPath:(FilterIndexPath*)indexPath;
@end

@protocol SKTFilterViewDelegate <NSObject>

//@optional
/** 修改frame*/
- (void)changeTableViewFrameWithFilterView:(SKTFilterView*)filterView;

/** 添加联系人*/
- (void)filterView:(SKTFilterView*)filterView addAddressBookAtCurIndex:(NSInteger)curIndex;

/** 添加筛选项*/
- (void)addFilterItemWithFilterView:(SKTFilterView*)filter;

/** 清空筛选条件*/
- (void)removeAllConditionItemsWithFilterView:(SKTFilterView*)filterView;

/** 根据索引删除筛选条件项*/
- (void)filterView:(SKTFilterView*)filterView deleteConditionItemAtIndex:(NSInteger)index;

/** 添加筛选条件项*/
- (void)filterView:(SKTFilterView*)filterView addConditionItem:(FilterCondition*)conditionItem;

/** 顺序视图*/
- (void)filterView:(SKTFilterView*)filter sortViewDidSelectedAtRow:(NSInteger)row;

/** 找出浮点类型被选中的数据，要是没有选中数据，就默认显示第一条数据*/
- (FilterValue*)filterView:(SKTFilterView*)filter sliderValueAtCurrentSelectedRow:(NSInteger)row;

/** 删除条件 根据被删除条件的itemId获取filter*/
- (Filter*)filterView:(SKTFilterView*)filter filterItemAtId:(NSString*)itemId;

/** 确定筛选条件*/
- (void)filterView:(SKTFilterView*)filter conditionJsonArray:(NSArray*)jsonArray;
@end

@interface SKTFilterView : UIView

@property (strong, nonatomic) UITableView *filterLeftView;
@property (strong, nonatomic) UITableView *filterRightView;
@property (strong, nonatomic) UIView *addAddressBookFootView;
@property (strong, nonatomic) UILabel *addAddressBookFootLabel;
@property (assign, nonatomic) NSInteger conditionCount;
@property (assign, nonatomic) NSInteger currentSelectedRow;     // 筛选一级视图当前选中行

@property (weak, nonatomic) id<SKTFilterViewDataSource>dataSource;
@property (weak, nonatomic) id<SKTFilterViewDelegate>delegate;

- (void)backgroundTap;
- (void)reloadRightTableView;
@end
