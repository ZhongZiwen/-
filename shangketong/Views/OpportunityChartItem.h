//
//  OpportunityChartItem.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/7/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpportunityChartItem : NSObject

@property (nonatomic, copy) NSString *m_dateString;
@property (nonatomic, copy) NSString *m_fillColor;
@property (nonatomic, assign) NSInteger m_yValue;
@property (nonatomic, assign) NSInteger m_radius;

+ (OpportunityChartItem*)initWithDictionary:(NSDictionary*)dict;
- (OpportunityChartItem*)initWithDictionary:(NSDictionary*)dict;
@end
