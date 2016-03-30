//
//  PerformanceItem.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PerformanceItem : NSObject

@property (nonatomic, copy) NSString *m_id;
@property (nonatomic, copy) NSString *m_name;
@property (nonatomic, copy) NSString *m_ownerId;
@property (nonatomic, copy) NSString *m_accountId;
@property (nonatomic, assign) NSInteger m_money;

+ (PerformanceItem*)initWithDictionary:(NSDictionary*)dict;
- (PerformanceItem*)initWithDictionary:(NSDictionary*)dict;
@end
