//
//  VisitingItem.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityItem : NSObject

@property (nonatomic, copy) NSString *m_id;
@property (nonatomic, copy) NSString *m_content;
@property (nonatomic, copy) NSString *m_groupBelongName;
@property (nonatomic, copy) NSString *m_groupName;
@property (nonatomic, copy) NSString *m_time;

+ (ActivityItem*)initWithDictionary:(NSDictionary*)dict;
- (ActivityItem*)initWithDictionary:(NSDictionary*)dict;
@end
