//
//  UIViewController+CustomTitleView.m
//  shangketong
//
//  Created by sungoin-zbs on 16/1/27.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "UIViewController+CustomTitleView.h"
#import "ActivityController.h"
#import "LeadViewController.h"
#import "CustomerViewController.h"
#import "ContactViewController.h"
#import "OpportunityViewController.h"

@implementation UIViewController (CustomTitleView)

static char titleViewKey, indexArrayKey, curIndexKey;

- (void)setTitleView:(CustomTitleView *)titleView {
    [self willChangeValueForKey:@"titleViewKey"];
    objc_setAssociatedObject(self, &titleViewKey, titleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"titleViewKey"];
}

- (CustomTitleView *)titleView {
    return objc_getAssociatedObject(self, &titleViewKey);
}

- (void)setIndexArray:(NSMutableArray *)indexArray {
    [self willChangeValueForKey:@"indexArrayKey"];
    objc_setAssociatedObject(self, &indexArrayKey, indexArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"indexArrayKey"];
}

- (NSMutableArray *)indexArray {
    return objc_getAssociatedObject(self, &indexArrayKey);
}

- (void)setCurIndex:(IndexCondition *)curIndex {
    [self willChangeValueForKey:@"curIndexKey"];
    objc_setAssociatedObject(self, &curIndexKey, curIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"curIndexKey"];
}

- (IndexCondition *)curIndex {
    return objc_getAssociatedObject(self, &curIndexKey);
}

#pragma mark - public method
- (void)configTitleViewWithTableName:(NSString *)tableName currentIndexKey:(NSString *)indexKey {
    // 获取缓存索引数据
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *curIndexData = [defaults objectForKey:kIndexStatus_activity];
    self.curIndex = [NSKeyedUnarchiver unarchiveObjectWithData:curIndexData];
    
    self.indexArray = [[FMDBManagement sharedFMDBManager] getCRMDataWithName:tableName conditionId:@-1 sortId:@-1];
    
    // 离线索引
    self.titleView.sourceArray = self.indexArray;
    // 获取离线索引对应的缓存数据
    if (self.curIndex.id) {
        for (int i = 0; i < self.indexArray.count; i ++) {
            IndexCondition *tempIndex = self.indexArray[i];
            if ([tempIndex.id isEqualToNumber:self.curIndex.id]) {
                self.titleView.index = i;
                break;
            }
        }
    }
    // 离线索引为nil，且非市场活动，获取最近浏览缓存数据
    if (self.curIndex && !self.curIndex.id && ![tableName isEqualToString:kTableName_activity]) {
        self.titleView.index = self.indexArray.count - 1;
    }
    
    if (!self.titleView) {
        self.titleView = [[CustomTitleView alloc] init];
        self.titleView.cellType = CellTypeDefault;
        self.titleView.superViewController = self;
    }
}

- (void)sendRequestForIndex {
    NSString *methodName;
    if ([self isKindOfClass:[ActivityController class]]) {
        methodName = kNetPath_Activity_Select_List;
    }
    else if ([self isKindOfClass:[LeadViewController class]]) {
        methodName = kNetPath_Lead_Select_List;
    }
    else if ([self isKindOfClass:[CustomerViewController class]]) {
        methodName = kNetPath_Customer_Select_List;
    }
    else if ([self isKindOfClass:[ContactViewController class]]) {
        methodName = kNetPath_Contact_Select_List;
    }
    else if ([self isKindOfClass:[OpportunityViewController class]]) {
        methodName = kNetPath_SaleChance_Select_List;
    }
    
    [[Net_APIManager sharedManager] request_CRM_Common_Index_WithPath:methodName block:^(id data, NSError *error) {
        if (data) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"conditions"]) {
                IndexCondition *item = [NSObject objectOfClass:@"IndexCondition" fromJSON:tempDict];
                [tempArray addObject:item];
                
                // 若没有索引缓存，去服务器返回默认显示的index
                if ([item.id isEqualToNumber:data[@"id"]] && !self.curIndex) {
                    self.curIndex = item;
                }
            }
            
            // 最近浏览(市场活动没有最近浏览)
            if (![self isKindOfClass:[ActivityController class]]) {
                IndexCondition *recentlyItem = [[IndexCondition alloc] init];
                recentlyItem.name = @"最近浏览";
                [tempArray insertObject:recentlyItem atIndex:tempArray.count];
            }
            
            self.indexArray = tempArray;
            self.titleView.sourceArray = self.indexArray;
            // 显示缓存索引的行
            if (self.curIndex && !self.curIndex.id) { // 缓存行curIndex不为空，但id为空，则表示是最近浏览缓存
                self.titleView.index = self.indexArray.count - 1;
            }
            else {
                for (int i = 0; i < self.indexArray.count; i ++) {
                    IndexCondition *tempIndex = self.indexArray[i];
                    if ([tempIndex.id isEqualToNumber:self.curIndex.id]) {
                        self.titleView.index = i;
                        break;
                    }
                }
            }

            // 最近浏览时，不进行网络请求
            if (self.curIndex && !self.curIndex.id) {
                [self.view endLoading];
                return;
            }
            
            // 请求列表数据
            if ([self isKindOfClass:[ActivityController class]]) {
                ActivityController *activityController = (ActivityController *)self;
                [activityController.params setObject:self.curIndex.id forKey:@"retrievalId"];
                [activityController sendRequest];
            }
            else if ([self isKindOfClass:[LeadViewController class]]) {
                LeadViewController *leadController = (LeadViewController *)self;
                [leadController.params setObject:self.curIndex.id forKey:@"retrievalId"];
                [leadController sendRequest];
            }
            else if ([self isKindOfClass:[CustomerViewController class]]) {
                CustomerViewController *customerController = (CustomerViewController *)self;
                [customerController.params setObject:self.curIndex.id forKey:@"retrievalId"];
                [customerController sendRequest];
            }
            else if ([self isKindOfClass:[ContactViewController class]]) {
                ContactViewController *contactController = (ContactViewController *)self;
                [contactController.params setObject:self.curIndex.id forKey:@"retrievalId"];
                [contactController sendRequest];
            }
            else if ([self isKindOfClass:[OpportunityViewController class]]) {
                OpportunityViewController *controller = (OpportunityViewController *)self;
                [controller.params setObject:self.curIndex.id forKey:@"retrievalId"];
                if (controller.isStageList) { // 销售阶段
                    [controller sendRequestForOpportunityStageList];
                }else {
                    [controller.params setObject:controller.curSort.id forKey:@"order"];
                    [controller sendRequestForOpportunityList];
                }
            }
        }
        else {
            [self.view endLoading];
        }
    }];
}

- (void)sendRequestRefreshForIndex {
    NSString *methodName;
    if ([self isKindOfClass:[ActivityController class]]) {
        methodName = kNetPath_Activity_Select_List;
    }
    else if ([self isKindOfClass:[LeadViewController class]]) {
        methodName = kNetPath_Lead_Select_List;
    }
    else if ([self isKindOfClass:[CustomerViewController class]]) {
        methodName = kNetPath_Customer_Select_List;
    }
    else if ([self isKindOfClass:[ContactViewController class]]) {
        methodName = kNetPath_Contact_Select_List;
    }
    else if ([self isKindOfClass:[OpportunityViewController class]]) {
        methodName = kNetPath_SaleChance_Select_List;
    }
    
    [[Net_APIManager sharedManager] request_CRM_Common_Index_WithPath:methodName block:^(id data, NSError *error) {
        if (data) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"conditions"]) {
                IndexCondition *item = [NSObject objectOfClass:@"IndexCondition" fromJSON:tempDict];
                [tempArray addObject:item];
            }
            
            // 最近浏览(市场活动没有最近浏览)
            if (![self isKindOfClass:[ActivityController class]]) {
                IndexCondition *recentlyItem = [[IndexCondition alloc] init];
                recentlyItem.name = @"最近浏览";
                [tempArray insertObject:recentlyItem atIndex:tempArray.count];
            }
            
            self.indexArray = tempArray;
            self.titleView.sourceArray = self.indexArray;
            // 显示缓存索引的行
            if (self.curIndex && !self.curIndex.id) { // 缓存行curIndex不为空，但id为空，则表示是最近浏览缓存
                self.titleView.index = self.indexArray.count - 1;
            }
            else {
                for (int i = 0; i < self.indexArray.count; i ++) {
                    IndexCondition *tempIndex = self.indexArray[i];
                    if ([tempIndex.id isEqualToNumber:self.curIndex.id]) {
                        self.titleView.index = i;
                        break;
                    }
                }
            }
        }
    }];
}

@end
