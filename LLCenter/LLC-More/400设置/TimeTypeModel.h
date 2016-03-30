//
//  TimeTypeModel.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeTypeModel : NSObject

/*
 sitWeek	String	选填	座席时间（比如：周一、周二）
 sitPointStartTime	String	必选	座席指定开始时间
 sitPointEndTime	String	必选	座席指定结束时间
 */
@property (nonatomic, assign) Boolean checked;
@property (nonatomic, copy) NSString *sitWeek;
@property (nonatomic, copy) NSString *sitWeekValue;
@property (nonatomic, copy) NSString *sitPointStartTime;
@property (nonatomic, copy) NSString *sitPointEndTime;


+ (TimeTypeModel*)initWithDataSource:(NSDictionary*)dict;
- (TimeTypeModel*)initWithDataSource:(NSDictionary*)dict;

@end
