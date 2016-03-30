//
//  ChartDataItem.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChartDataItem : NSObject

@property (nonatomic, copy) NSString *m_uid;
@property (nonatomic, copy) NSString *m_id;
@property (nonatomic, copy) NSString *m_name;
@property (nonatomic, copy) NSString *m_count;

+ (ChartDataItem*)initWithDictionary:(NSDictionary*)dict;
- (ChartDataItem*)initWithDictionary:(NSDictionary*)dict;
@end
