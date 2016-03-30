//
//  ChartItem.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChartItem : NSObject

@property (nonatomic, copy) NSString *m_id;
@property (nonatomic, copy) NSString *m_name;
@property (nonatomic, copy) NSString *m_viewCase;
@property (nonatomic, copy) NSString *m_description;
@property (nonatomic, copy) NSString *m_dataDisplay;
@property (nonatomic, copy) NSString *m_type;

- (ChartItem*)initWithDictionary:(NSDictionary*)dict;
+ (ChartItem*)initWithDictionary:(NSDictionary*)dict;
@end
