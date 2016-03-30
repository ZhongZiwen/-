//
//  FilterIndexPath.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FilterType) {
    FilterTypeSort = 0,      // 顺序筛选
    FilterTypeConditionLeft, // 条件left筛选
    FilterTypeConditionRight // 条件right筛选
};

@interface FilterIndexPath : NSObject

@property (assign, nonatomic) FilterType type;
@property (assign, nonatomic) NSInteger row;        // 条件筛选中第一级列表的row
@property (assign, nonatomic) NSInteger item;       // 条件筛选中第二级列表的row

- (instancetype)initIndexPathWithType:(FilterType)type row:(NSInteger)row;
+ (instancetype)initIndexPathWithType:(FilterType)type row:(NSInteger)row;
- (instancetype)initIndexPathWithType:(FilterType)type row:(NSInteger)row item:(NSInteger)item;
+ (instancetype)initIndexPathWithType:(FilterType)type row:(NSInteger)row item:(NSInteger)item;
@end
