//
//  SKTIndexPath.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SKTIndexPathType) {
    SKTIndexPathTypeSmartView = -1,   // 导航栏条件
    SKTIndexPathTypeScreening = 1,   // 筛选
    SKTIndexPathTypeOther = 0
};

@interface SKTIndexPath : NSObject

@property (nonatomic, assign) SKTIndexPathType type;  // menu的类型
@property (nonatomic, assign) NSInteger row;          // 第一级导航列表的row
@property (nonatomic, assign) NSInteger item;         // 第二级导航列表的row

- (instancetype)initIndexPathWithType:(SKTIndexPathType)type andRow:(NSInteger)row;
- (instancetype)initIndexPathWithType:(SKTIndexPathType)type andRow:(NSInteger)row andItem:(NSInteger)item;
+ (instancetype)initIndexPathWithType:(SKTIndexPathType)type andRow:(NSInteger)row;
+ (instancetype)initIndexPathWithType:(SKTIndexPathType)type andRow:(NSInteger)row andItem:(NSInteger)item;
@end
