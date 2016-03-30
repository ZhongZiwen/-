//
//  Filter.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Filter : NSObject<NSCoding>

@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSNumber *searchType;     // 0单选 1多选 3员工 4浮点
@property (strong, nonatomic) NSMutableArray *valuesArray;
@property (strong, nonatomic) NSNumber *columnType;     // 
@property (strong, nonatomic) NSNumber *showWhenInit;

@property (assign, nonatomic) BOOL isCondition;         // 条件数据是否有该组值，用于标记小圆点
@property (assign, nonatomic) BOOL isExpand;            // 浮点类型（是否展开）
@property (assign, nonatomic) NSInteger leftValue;      // 浮点类型(左边的值)
@property (assign, nonatomic) NSInteger rightValue;     // 浮点类型(右边的值)
@end
