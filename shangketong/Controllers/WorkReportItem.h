//
//  WorkReportItem.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkReportItem : NSObject<NSCoding>

@property (nonatomic, assign) NSInteger m_reportID;     // 报告id

@property (nonatomic, copy) NSString *m_reportType;     // 报告类型
@property (nonatomic, copy) NSString *m_reportTypeName; // 日报 周报 月报
@property (nonatomic, assign) NSInteger m_reportTypeIndex; // 0:日报 1:周报 2:月报

@property (nonatomic, copy) NSString *m_reportTime;
@property (nonatomic, copy) NSString *m_createAt;
@property (nonatomic, assign) BOOL m_paperStatus;       // 是否草稿 0:不是草稿 1:草稿
@property (nonatomic, assign) BOOL m_readStatus;        // 是否批阅 0:已阅 1:未阅
@property (nonatomic, copy) NSString *m_creatorIcon;    // 创建人头像
@property (nonatomic, copy) NSString *m_creatorId;      // 创建人id
@property (nonatomic, copy) NSString *m_creatorName;    // 创建人名字


@property (nonatomic, copy) NSString *m_reveiwerId;      // 批阅人id

+ (WorkReportItem*)initWithDictionary:(NSDictionary*)dict;
- (WorkReportItem*)initWithDictionary:(NSDictionary*)dict;
@end
