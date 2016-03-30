//
//  WorkReportNewItem.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WRNewItem : NSObject

@property (nonatomic, assign) NSInteger m_columnType;   // 字段类型 1文本  2文本域  3单选框  4多选框  5整数 6浮点数  7日期型
@property (nonatomic, copy) NSString *m_name;
@property (nonatomic, copy) NSString *m_propertyName;
@property (nonatomic, copy) NSString *m_object;
@property (nonatomic, copy) NSString *m_result;
@property (nonatomic, assign) NSInteger m_required;          // 必填或选填
@property (nonatomic, strong) NSArray *m_selectArray;   // 单选或多选保存的数据

@property (nonatomic, assign) NSInteger m_fullDate;          // 后台时间动态字段  是否开启  0开启   1未开启

+ (WRNewItem*)initWithDictionary:(NSDictionary*)dict;
- (WRNewItem*)initWithDictionary:(NSDictionary*)dict;
@end
