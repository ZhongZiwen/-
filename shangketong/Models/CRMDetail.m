//
//  CRMDetail.m
//  shangketong
//
//  Created by sungoin-zbs on 16/1/6.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "CRMDetail.h"

@implementation CRMDetail

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)configStaffArray:(NSArray *)array {
    // 排序
    NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(DetailStaffModel *obj1, DetailStaffModel *obj2) {
        NSComparisonResult result = [obj1.staffLevel compare:obj2.staffLevel];
        return result;
    }];
    _staffsArray = [[NSMutableArray alloc] initWithArray:sortArray];
}

- (void)configColumnsShowArray {
    
    NSMutableArray *tempInfoShowArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *tempInfoRemoveArray = [NSMutableArray arrayWithCapacity:0];
    
    for (ColumnModel *tempColumn in _columnsArray) {
        if (![tempColumn.showWhenInit integerValue]) {
            [tempInfoShowArray addObject:tempColumn];
        }
    }
    
    for (int i = 0; i < tempInfoShowArray.count; i ++) {
        ColumnModel *item = tempInfoShowArray[i];
        if (i == tempInfoShowArray.count - 1 && [item.columnType isEqualToNumber:@8]) {
            [tempInfoRemoveArray addObject:item];
        }else if (i) {
            ColumnModel *preItem = tempInfoShowArray[i - 1];
            if ([preItem.columnType isEqualToNumber:@8] && [item.columnType isEqualToNumber:@8]) {
                [tempInfoRemoveArray addObject:preItem];
            }
        }
    }
    for (ColumnModel *tempItem in tempInfoRemoveArray) {
        [tempInfoShowArray removeObject:tempItem];
    }
    
    _columnsShowArray = tempInfoShowArray;
}
@end
