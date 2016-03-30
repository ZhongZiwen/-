//
//  FilterValue.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AddressBook;

@interface FilterValue : NSObject<NSCoding>

@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *name;

@property (copy, nonatomic) NSString *icon;         // 选择员工类型中能用到
@property (assign, nonatomic) BOOL isSelected;      // 显示默认第一项，id为nill时，做显示标识

// 员工选择，数据模型转换
+ (FilterValue*)initWithModel:(AddressBook*)item;
- (FilterValue*)initWithModel:(AddressBook*)item;
@end
