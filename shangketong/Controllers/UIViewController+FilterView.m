//
//  UIViewController+FilterView.m
//  shangketong
//
//  Created by sungoin-zbs on 16/1/26.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "UIViewController+FilterView.h"
#import "FilterSelectedController.h"
#import <SBJson4Writer.h>

#import "AddressBook.h"
#import "ExportAddressViewController.h"
#import "ExportAddress.h"
#import "EditAddressViewController.h"

#import "ActivityController.h"
#import "LeadViewController.h"
#import "CustomerViewController.h"
#import "ContactViewController.h"
#import "OpportunityViewController.h"

@implementation UIViewController (FilterView)

static char filterShowArrayKey, filterHiddenArrayKey, conditionArrayKey, sortArrayKey, jsonArrayKey, filterViewKey, curSortKey;

- (void)setFilterShowArray:(NSMutableArray *)filterShowArray {
    [self willChangeValueForKey:@"filterShowArrayKey"];
    objc_setAssociatedObject(self, &filterShowArrayKey, filterShowArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"filterShowArrayKey"];
}

- (NSMutableArray *)filterShowArray {
    return objc_getAssociatedObject(self, &filterShowArrayKey);
}

- (void)setFilterHiddenArray:(NSMutableArray *)filterHiddenArray {
    [self willChangeValueForKey:@"filterHiddenArrayKey"];
    objc_setAssociatedObject(self, &filterHiddenArrayKey, filterHiddenArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"filterHiddenArrayKey"];
}

- (NSMutableArray *)filterHiddenArray {
    return objc_getAssociatedObject(self, &filterHiddenArrayKey);
}

- (void)setConditionArray:(NSMutableArray *)conditionArray {
    [self willChangeValueForKey:@"conditionArrayKey"];
    objc_setAssociatedObject(self, &conditionArrayKey, conditionArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"conditionArrayKey"];
}

- (NSMutableArray *)conditionArray {
    return objc_getAssociatedObject(self, &conditionArrayKey);
}

- (void)setSortArray:(NSArray *)sortArray {
    [self willChangeValueForKey:@"sortArrayKey"];
    objc_setAssociatedObject(self, &sortArrayKey, sortArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"sortArrayKey"];
}

- (NSArray *)sortArray {
    return objc_getAssociatedObject(self, &sortArrayKey);
}

- (void)setJsonArray:(NSArray *)jsonArray {
    [self willChangeValueForKey:@"jsonArrayKey"];
    objc_setAssociatedObject(self, &jsonArrayKey, jsonArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"jsonArrayKey"];
}

- (NSArray *)jsonArray {
    return objc_getAssociatedObject(self, &jsonArrayKey);
}

#pragma mark - curSort
- (void)setCurSort:(IndexCondition *)curSort {
    [self willChangeValueForKey:@"curSortKey"];
    objc_setAssociatedObject(self, &curSortKey, curSort, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"curSortKey"];
}

- (IndexCondition *)curSort {
    return objc_getAssociatedObject(self, &curSortKey);
}

#pragma mark - FilterView
- (void)setFilterView:(SKTFilterView *)filterView {
    [self willChangeValueForKey:@"filterViewKey"];
    objc_setAssociatedObject(self, &filterViewKey, filterView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"filterViewKey"];
}

- (SKTFilterView *)filterView {
    return objc_getAssociatedObject(self, &filterViewKey);
}

#pragma mark - public method
- (void)configFilterWithTableName:(NSString *)tableName currentSortKey:(NSString *)sortKey {
    if ([tableName isEqualToString:kTableName_activity]) {
        self.sortArray = @[[IndexCondition initWithId:@1 name:@"最新创建"], [IndexCondition initWithId:@2 name:@"最近活动记录"]];
        
    }
    else if ([tableName isEqualToString:kTableName_lead]) {
        self.sortArray = @[[IndexCondition initWithId:@1 name:@"最新创建"], [IndexCondition initWithId:@2 name:@"最近活动记录"], [IndexCondition initWithId:@3 name:@"最新分配或认领"], [IndexCondition initWithId:@4 name:@"最近到期"]];
    }
    else if ([tableName isEqualToString:kTableName_customer]) {
        self.sortArray = @[[IndexCondition initWithId:@1 name:@"最新创建"], [IndexCondition initWithId:@2 name:@"最近活动记录"], [IndexCondition initWithId:@3 name:@"最近到期"]];
    }
    else if ([tableName isEqualToString:kTableName_contact]) {
        self.sortArray = @[[IndexCondition initWithId:@1 name:@"最新创建"], [IndexCondition initWithId:@2 name:@"最近活动记录"]];
    }
    else if ([tableName isEqualToString:kTableName_opportunity]) {
        self.sortArray = @[[IndexCondition initWithId:@1 name:@"销售阶段"], [IndexCondition initWithId:@5 name:@"最高销售额"], [IndexCondition initWithId:@2 name:@"最近活动记录"]];
    }
    
    // 获取退后退出视图缓存的排序
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *curSortData = [defaults objectForKey:sortKey];
    self.curSort = [NSKeyedUnarchiver unarchiveObjectWithData:curSortData];
    
    // 获取缓存筛选数据
    self.filterShowArray = [[FMDBManagement sharedFMDBManager] getCRMDataWithName:tableName conditionId:@-2 sortId:@-2];
    self.filterHiddenArray = [[FMDBManagement sharedFMDBManager] getCRMDataWithName:tableName conditionId:@-3 sortId:@-3];
    // 筛选条件缓存
    self.conditionArray = [[FMDBManagement sharedFMDBManager] getCRMDataWithName:tableName conditionId:@-4 sortId:@-4];
    // 筛选json缓存
    self.jsonArray = [[FMDBManagement sharedFMDBManager] getCRMDataWithName:tableName conditionId:@-5 sortId:@-5];
    
    if (!self.conditionArray || !self.conditionArray.count) {
        self.conditionArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    // 没有排序缓存
    if (!self.curSort) {
        if ([tableName isEqualToString:kTableName_opportunity]) {
            self.curSort = [IndexCondition initWithId:@1 name:@"销售阶段"];
        }
        else {
            self.curSort = [IndexCondition initWithId:@1 name:@"最新创建"];
        }
    }
    
    if (!self.filterView) {
        self.filterView = [[SKTFilterView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, 44)];
        self.filterView.delegate = self;
        self.filterView.dataSource = self;
        [self.view addSubview:self.filterView];
    }
    
    // 如果存在缓存数据，默认显示leftTableView的第一行数据
    if (self.filterShowArray.count) {
        self.filterView.currentSelectedRow = 0;
    }
}

- (void)hideFilterView {
    [self.filterView backgroundTap];
}

- (void)sendRequestForFilter {
    
    NSString *methodName;
    if ([self isKindOfClass:[ActivityController class]]) {
        methodName = kNetPath_Activity_Filter;
    }
    else if ([self isKindOfClass:[LeadViewController class]]) {
        methodName = kNetPath_Lead_Filter;
    }
    else if ([self isKindOfClass:[CustomerViewController class]]) {
        methodName = kNetPath_Customer_Filter;
    }
    else if ([self isKindOfClass:[ContactViewController class]]) {
        methodName = kNetPath_Contact_Filter;
    }
    else if ([self isKindOfClass:[OpportunityViewController class]]) {
        methodName = kNetPath_SaleChance_Filter;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Net_APIManager sharedManager] request_CRM_Common_Filter_WithPath:methodName block:^(id data, NSError *error) {
            if (data) {
                NSMutableArray *showArray = [[NSMutableArray alloc] initWithCapacity:0];
                NSMutableArray *hiddenArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary *tempDict in [data objectForKey:@"filters"]) {
                    Filter *filter = [NSObject objectOfClass:@"Filter" fromJSON:tempDict];
                    for (NSDictionary *valueDict in [tempDict objectForKey:@"values"]) {
                        FilterValue *value = [NSObject objectOfClass:@"FilterValue" fromJSON:valueDict];
                        value.isSelected = value.id ? NO : YES;  // 不限选项的区分
                        [filter.valuesArray addObject:value];
                    }
                    
                    // 存在缓存选中筛选条件时，匹配数据，修改状态
                    for (FilterCondition *tempCondition in self.conditionArray) {
                        
                        if ([tempCondition.itemId isEqualToString:filter.id]) {
                            filter.isCondition = YES;
                            filter.showWhenInit = @0;
                            for (FilterValue *tempValue in filter.valuesArray) {
                                
                                // 浮点类型
                                if ([tempCondition.itemSearchType integerValue] == 4 && [tempCondition.sliderValueId isEqualToString:tempValue.id]) {
                                    tempValue.isSelected = YES;
                                }
                                else {
                                    // 修改不限的状态(不限的状态，服务器返回nil)
                                    if (!tempValue.id) {
                                        tempValue.isSelected = NO;
                                    }
                                    
                                    if ([tempValue.id isEqualToString:tempCondition.value]) {
                                        tempValue.isSelected = YES;
                                    }
                                }
                                
                            }
                            
                            // 浮点类型，赋左右值
                            if ([tempCondition.itemSearchType integerValue] == 4) {
                                filter.leftValue = [tempCondition.sliderLeftValue integerValue];
                                filter.rightValue = [tempCondition.sliderRightValue integerValue];
                            }
                        }
                    }
                    
                    if ([filter.showWhenInit integerValue]) {
                        [hiddenArray addObject:filter];
                    }else {
                        [showArray addObject:filter];
                    }
                }
                
                // 筛选为员工类型时，显示缓存的员工列表
                for (Filter *casheFilter in self.filterShowArray) {
                    if ([casheFilter.searchType isEqualToNumber:@3]) {
                        for (Filter *tempFilter in showArray) {
                            if ([tempFilter.id isEqualToString:casheFilter.id]) {
                                tempFilter.valuesArray = casheFilter.valuesArray;
                                break;
                            }
                        }
                    }
                }
                
                for (Filter *casheFilter in self.filterHiddenArray) {
                    if ([casheFilter.searchType isEqualToNumber:@3]) {
                        for (Filter *tempFilter in hiddenArray) {
                            if ([tempFilter.id isEqualToString:casheFilter.id]) {
                                tempFilter.valuesArray = casheFilter.valuesArray;
                                break;
                            }
                        }
                    }
                }
                
                self.filterShowArray = showArray;
                self.filterHiddenArray = hiddenArray;
                self.filterView.currentSelectedRow = 0;
            }
        }];
    });
}

#pragma mark - SKTFilterViewDataSource
- (IndexCondition*)currentSortWithFilterView:(SKTFilterView *)filterView {
    return self.curSort;
}

- (NSArray*)conditionArrayWithFilterView:(SKTFilterView *)filterView {
    return self.conditionArray;
}

- (NSInteger)filterView:(SKTFilterView *)filter numberOfRowsInType:(FilterType)type {
    if (type == FilterTypeSort) {
        return self.sortArray.count;
    }
    
    return self.filterShowArray.count;
}

- (NSInteger)filterView:(SKTFilterView *)filter numberOfItemsInRow:(NSInteger)row {
    if (self.filterShowArray.count) {
        Filter *filterItem = self.filterShowArray[row];
        if ([filterItem.searchType integerValue] == 4 && !filterItem.isExpand) {
            return 0;
        }
        
        return filterItem.valuesArray.count;
    }
    
    return 0;
}

- (id)filterView:(SKTFilterView *)filter sourceForRowAtIndexPath:(FilterIndexPath *)indexPath {
    if (indexPath.type == FilterTypeSort) {
        IndexCondition *item = self.sortArray[indexPath.row];
        return item.name;
    }else if (indexPath.type == FilterTypeConditionLeft) {
        return self.filterShowArray[indexPath.row];
    }else {
        Filter *filterItem = self.filterShowArray[indexPath.row];
        return filterItem.valuesArray[indexPath.item];
    }
}

#pragma mark - SKTFilterViewDelegate
- (void)filterView:(SKTFilterView *)filter sortViewDidSelectedAtRow:(NSInteger)row {
    self.curSort = self.sortArray[row];
    
    if ([self isKindOfClass:[ActivityController class]]) {
        ActivityController *activityController = (ActivityController *)self;
        [activityController.params setObject:self.curSort.id forKey:@"order"];
        
        [self.view beginLoading];
        [activityController sendRequest];
    }
    else if ([self isKindOfClass:[LeadViewController class]]) {
        LeadViewController *leadController = (LeadViewController *)self;
        [leadController.params setObject:self.curSort.id forKey:@"order"];
        
        [self.view beginLoading];
        [leadController sendRequest];
    }
    else if ([self isKindOfClass:[CustomerViewController class]]) {
        CustomerViewController *customerController = (CustomerViewController *)self;
        [customerController.params setObject:self.curSort.id forKey:@"order"];
        
        [self.view beginLoading];
        [customerController sendRequest];
    }
    else if ([self isKindOfClass:[ContactViewController class]]) {
        ContactViewController *contactController = (ContactViewController *)self;
        [contactController.params setObject:self.curSort.id forKey:@"order"];
        
        [self.view beginLoading];
        [contactController sendRequest];
    }
    else if ([self isKindOfClass:[OpportunityViewController class]]) {
        OpportunityViewController *controller = (OpportunityViewController *)self;
        if (row == 0) {
            controller.isStageList = YES;
            [controller.params removeObjectForKey:@"order"];
            [controller sendRequestForOpportunityStageList];
            [controller.bottomView removeFromSuperview];
        }else {
            controller.isStageList = NO;
            [controller.params setObject:controller.curSort.id forKey:@"order"];
            [controller sendRequestForOpportunityList];
            [self.view addSubview:controller.bottomView];
        }
    }
}

- (void)changeTableViewFrameWithFilterView:(SKTFilterView *)filterView {
    if ([self isKindOfClass:[ActivityController class]]) {
        ActivityController *activityController = (ActivityController *)self;

        [activityController.tableView setY:CGRectGetMaxY(filterView.frame)];
        [activityController.tableView setHeight:kScreen_Height - CGRectGetMinY(activityController.tableView.frame)];
    }
    else if ([self isKindOfClass:[LeadViewController class]]) {
        LeadViewController *leadController = (LeadViewController *)self;
        if ([leadController.curIndex.name isEqualToString:@"最近浏览"]) {
            leadController.filterView.hidden = YES;
            [leadController.tableView setY:64.0f];
            [leadController.tableView setHeight:kScreen_Height - CGRectGetMinY(leadController.tableView.frame)];
            [leadController.tableView configBlankPageWithTitle:@"暂无最近浏览记录" hasData:leadController.sourceArray.count hasError:NO reloadButtonBlock:nil];
            return;
        }
        
        [leadController.tableView setY:CGRectGetMaxY(filterView.frame)];
        [leadController.tableView setHeight:kScreen_Height - CGRectGetMinY(leadController.tableView.frame)];
    }
    else if ([self isKindOfClass:[CustomerViewController class]]) {
        CustomerViewController *customerController = (CustomerViewController *)self;
        if ([customerController.curIndex.name isEqualToString:@"最近浏览"]) {
            customerController.filterView.hidden = YES;
            [customerController.tableView setY:64.0f];
            [customerController.tableView setHeight:kScreen_Height - CGRectGetMinY(customerController.tableView.frame)];
            [customerController.tableView configBlankPageWithTitle:@"暂无最近浏览记录" hasData:customerController.sourceArray.count hasError:NO reloadButtonBlock:nil];
            return;
        }
        
        [customerController.tableView setY:CGRectGetMaxY(filterView.frame)];
        [customerController.tableView setHeight:kScreen_Height - CGRectGetMinY(customerController.tableView.frame)];
    }
    else if ([self isKindOfClass:[ContactViewController class]]) {
        ContactViewController *contactController = (ContactViewController *)self;
        if ([contactController.curIndex.name isEqualToString:@"最近浏览"]) {
            contactController.filterView.hidden = YES;
            [contactController.tableView setY:64.0f];
            [contactController.tableView setHeight:kScreen_Height - CGRectGetMinY(contactController.tableView.frame)];
            [contactController.tableView configBlankPageWithTitle:@"暂无最近浏览记录" hasData:contactController.sourceArray.count hasError:NO reloadButtonBlock:nil];
            return;
        }
        
        [contactController.tableView setY:CGRectGetMaxY(filterView.frame)];
        [contactController.tableView setHeight:kScreen_Height - CGRectGetMinY(contactController.tableView.frame)];
    }
    else if ([self isKindOfClass:[OpportunityViewController class]]) {
        OpportunityViewController *controller = (OpportunityViewController *)self;
        if ([controller.curIndex.name isEqualToString:@"最近浏览"]) {
            controller.filterView.hidden = YES;
            controller.bottomView.hidden = YES;
            [controller.tableView setY:64.0f];
            [controller.tableView setHeight:kScreen_Height - CGRectGetMinY(controller.tableView.frame)];
            return;
        }
        
        [controller.tableView setY:CGRectGetMaxY(filterView.frame)];
        if ([controller.curSort.name isEqualToString:@"销售阶段"]) {
            [controller.tableView setHeight:kScreen_Height - CGRectGetMinY(controller.tableView.frame)];
        }
        else {
            [controller.tableView setHeight:kScreen_Height - CGRectGetMinY(controller.tableView.frame) - CGRectGetHeight(controller.bottomView.bounds)];
        }
    }
}

- (void)filterView:(SKTFilterView *)filterView addAddressBookAtCurIndex:(NSInteger)curIndex {
    Filter *filter = self.filterShowArray[curIndex];
    
    if (filter.valuesArray.count) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
        for (FilterValue *tempItem in filter.valuesArray) {
            AddressBook *item = [AddressBook initWithFilter:tempItem];
            if (tempItem.isSelected) {
                item.isSelected = YES;
            }
            [tempArray addObject:item];
        }
        
        EditAddressViewController *editController = [[EditAddressViewController alloc] init];
        editController.title = [NSString stringWithFormat:@"选择常用%@", filter.itemName];
        editController.sourceModel = [ExportAddress initWithArray:tempArray];
        editController.addBlock = ^(AddressBook *item) {
            FilterValue *filterValue = [FilterValue initWithModel:item];
            filterValue.isSelected = YES;
            [filter.valuesArray addObject:filterValue];
            filter.isCondition = YES;
            [filterView.filterLeftView reloadData];
            [filterView reloadRightTableView];
            
            FilterCondition *conditionItem = [FilterCondition initWithFilter:filter filterValue:filterValue];
            [self.conditionArray addObject:conditionItem];
            
            filterView.conditionCount = self.conditionArray.count;
            filterView.filterRightView.tableFooterView = [[UIView alloc] init];
        };
        editController.deleteBlock = ^(AddressBook *item) {
            FilterValue *filterValue = [FilterValue initWithModel:item];
            FilterCondition *conditionItem = [FilterCondition initWithFilter:filter filterValue:filterValue];
            
            if (filterValue.isSelected) {
                for (FilterCondition *tempCondition in self.conditionArray) {
                    if ([tempCondition.itemId isEqualToString:conditionItem.itemId] && [tempCondition.value isEqualToString:conditionItem.value]) {
                        [self.conditionArray removeObject:tempCondition];
                        break;
                    }
                }
            }
            
            for (FilterValue *tempFilter in filter.valuesArray) {
                if ([tempFilter.id isEqualToString:filterValue.id]) {
                    [filter.valuesArray removeObject:tempFilter];
                    break;
                }
            }
            
            // 判断是否有条件
            BOOL isCondition = NO;
            for (FilterValue *tempFilter in filter.valuesArray) {
                if (tempFilter.isSelected) {
                    isCondition = YES;
                    break;
                }
            }
            filter.isCondition = isCondition;
            
            [filterView.filterLeftView reloadData];
            [filterView reloadRightTableView];
            filterView.conditionCount = self.conditionArray.count;
            
            if (filter.valuesArray.count) {
                filterView.filterRightView.tableFooterView = [[UIView alloc] init];
            }
            else {
                filterView.filterRightView.tableFooterView = filterView.addAddressBookFootView;
                
                NSString *str = [NSString stringWithFormat:@"您可以添加常用的%@，以便以后快速选择", filter.itemName];
                CGFloat height = [str getHeightWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(CGRectGetWidth(filterView.filterRightView.bounds), CGFLOAT_MAX)];
                
                filterView.addAddressBookFootLabel.text = str;
                [filterView.addAddressBookFootLabel setHeight:height];
                [filterView.addAddressBookFootView setHeight:height];
            }
        };
        [self.navigationItem setBackBarButtonItem:kBackItem];
        [self.navigationController pushViewController:editController animated:YES];
        return;
    }
    
    ExportAddressViewController *exportController = [[ExportAddressViewController alloc] init];
    exportController.title = [NSString stringWithFormat:@"选择常用%@", filter.itemName];
    exportController.isActivityRecExport = YES;
    exportController.valueBlock = ^(NSArray *array) {
        for (AddressBook *tempBook in array) {
            FilterValue *value = [FilterValue initWithModel:tempBook];
            value.isSelected = YES;
            [filter.valuesArray addObject:value];
            
            FilterCondition *conditionItem = [FilterCondition initWithFilter:filter filterValue:value];
            [self.conditionArray addObject:conditionItem];
        }
        
        if (filter.valuesArray.count) {
            filter.isCondition = YES;
            [filterView.filterLeftView reloadData];
            [filterView reloadRightTableView];
            filterView.conditionCount = self.conditionArray.count;
            filterView.filterRightView.tableFooterView = [[UIView alloc] init];
        }
    };
    [self.navigationController pushViewController:exportController animated:YES];
}

- (void)filterView:(SKTFilterView *)filterView addConditionItem:(FilterCondition *)conditionItem {
    switch ([conditionItem.itemSearchType integerValue]) {
        case 0: { // 单选
            for (int i = 0; i < self.conditionArray.count; i ++) {
                FilterCondition *tempCondition = self.conditionArray[i];
                if ([tempCondition.itemId isEqualToString:conditionItem.itemId]) {
                    [self.conditionArray replaceObjectAtIndex:i withObject:conditionItem];
                    return;
                }
            }
            [self.conditionArray addObject:conditionItem];
        }
            break;
        case 1: { // 多选
            [self.conditionArray addObject:conditionItem];
        }
            break;
        case 3: { // 员工
            [self.conditionArray addObject:conditionItem];
        }
            break;
        case 4: { // 浮点
            for (int i = 0; i < self.conditionArray.count; i ++) {
                FilterCondition *tempCondition = self.conditionArray[i];
                if ([tempCondition.itemId isEqualToString:conditionItem.itemId]) {
                    [self.conditionArray replaceObjectAtIndex:i withObject:conditionItem];
                    return;
                }
            }
            [self.conditionArray addObject:conditionItem];
        }
        default:
            break;
    }
}

- (void)filterView:(SKTFilterView *)filterView deleteConditionItemAtIndex:(NSInteger)index {
    if (index < self.conditionArray.count) {
        [self.conditionArray removeObjectAtIndex:index];
    }
}

- (void)removeAllConditionItemsWithFilterView:(SKTFilterView *)filterView {
    [self.conditionArray removeAllObjects];
}

- (Filter*)filterView:(SKTFilterView *)filter filterItemAtId:(NSString *)itemId {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.filterShowArray];
    [tempArray addObjectsFromArray:self.filterHiddenArray];
    
    for (Filter *tempFilter in tempArray) {
        if ([tempFilter.id isEqualToString:itemId]) {
            return tempFilter;
        }
    }
    return nil;
}

- (void)addFilterItemWithFilterView:(SKTFilterView *)filter {
    FilterSelectedController *filterSelectedController = [[FilterSelectedController alloc] init];
    filterSelectedController.selectedArray = self.filterShowArray;
    filterSelectedController.unSelectedArray = self.filterHiddenArray;
    filterSelectedController.refreshBlock = ^{
        self.filterView.currentSelectedRow = 0;
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:filterSelectedController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (FilterValue*)filterView:(SKTFilterView *)filter sliderValueAtCurrentSelectedRow:(NSInteger)row {
    Filter *filterItem = self.filterShowArray[row];
    for (FilterValue *tempValue in filterItem.valuesArray) {
        if (tempValue.isSelected) {
            return tempValue;
        }
    }
    
    FilterValue *firstValue = filterItem.valuesArray.firstObject;
    firstValue.isSelected = YES;
    return firstValue;
}

- (void)filterView:(SKTFilterView *)filter conditionJsonArray:(NSArray *)jsonArray {
    
    if ([self isKindOfClass:[ActivityController class]]) {
        // 缓存选中筛选数据
        [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_activity array:self.conditionArray conditionId:@-4 sortId:@-4];
        [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_activity array:jsonArray conditionId:@-5 sortId:@-5];
        
        ActivityController *activityController = (ActivityController *)self;
        if (jsonArray) {
            SBJson4Writer *jsonParser = [[SBJson4Writer alloc] init];
            NSString *jsonString = [jsonParser stringWithObject:jsonArray];
            [activityController.params setObject:jsonString forKey:@"filters"];
        }else {
            [activityController.params removeObjectForKey:@"filters"];
        }
        
        [self.view beginLoading];
        [activityController sendRequest];
    }
    else if ([self isKindOfClass:[LeadViewController class]]) {
        [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_lead array:self.conditionArray conditionId:@-4 sortId:@-4];
        [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_lead array:jsonArray conditionId:@-5 sortId:@-5];
        
        LeadViewController *leadController = (LeadViewController *)self;
        if (jsonArray) {
            SBJson4Writer *jsonParser = [[SBJson4Writer alloc] init];
            NSString *jsonString = [jsonParser stringWithObject:jsonArray];
            [leadController.params setObject:jsonString forKey:@"filters"];
        }else {
            [leadController.params removeObjectForKey:@"filters"];
        }
        
        [self.view beginLoading];
        [leadController sendRequest];
    }
    else if ([self isKindOfClass:[CustomerViewController class]]) {
        [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_customer array:self.conditionArray conditionId:@-4 sortId:@-4];
        [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_customer array:jsonArray conditionId:@-5 sortId:@-5];
        
        CustomerViewController *customerController = (CustomerViewController *)self;
        if (jsonArray) {
            SBJson4Writer *jsonParser = [[SBJson4Writer alloc] init];
            NSString *jsonString = [jsonParser stringWithObject:jsonArray];
            [customerController.params setObject:jsonString forKey:@"filters"];
        }else {
            [customerController.params removeObjectForKey:@"filters"];
        }
        
        [self.view beginLoading];
        [customerController sendRequest];
    }
    else if ([self isKindOfClass:[ContactViewController class]]) {
        [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_contact array:self.conditionArray conditionId:@-4 sortId:@-4];
        [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_contact array:jsonArray conditionId:@-5 sortId:@-5];
        
        ContactViewController *contactController = (ContactViewController *)self;
        if (jsonArray) {
            SBJson4Writer *jsonParser = [[SBJson4Writer alloc] init];
            NSString *jsonString = [jsonParser stringWithObject:jsonArray];
            [contactController.params setObject:jsonString forKey:@"filters"];
        }else {
            [contactController.params removeObjectForKey:@"filters"];
        }
        
        [self.view beginLoading];
        [contactController sendRequest];
    }
    else if ([self isKindOfClass:[OpportunityViewController class]]) {
        // 缓存选中筛选数据
        [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_opportunity array:self.conditionArray conditionId:@-4 sortId:@-4];
        [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_opportunity array:jsonArray conditionId:@-5 sortId:@-5];
        
        OpportunityViewController *opportunity = (OpportunityViewController *)self;
        if (jsonArray) {
            SBJson4Writer *jsonParser = [[SBJson4Writer alloc] init];
            NSString *jsonString = [jsonParser stringWithObject:jsonArray];
            [opportunity.params setObject:jsonString forKey:@"filters"];
        }else {
            [opportunity.params removeObjectForKey:@"filters"];
        }
        
        [self.view beginLoading];
        if (opportunity.isStageList) {
            [opportunity sendRequestForOpportunityStageList];
        }else {
            [opportunity sendRequestForOpportunityList];
        }
    }
}

@end
