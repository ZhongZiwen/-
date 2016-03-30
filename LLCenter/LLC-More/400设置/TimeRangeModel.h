//
//  TimeRangeModel.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeRangeModel : NSObject

/*
 weekValue		1,2,3,4,5,6,7
 weekStartTime	开始时间
 weekEndTime	结束时间
 */
@property (nonatomic, copy) NSString *weekValue;
@property (nonatomic, copy) NSString *weekStartTime;
@property (nonatomic, copy) NSString *weekEndTime;



+ (TimeRangeModel*)initWithDataSource:(NSDictionary*)dict;
- (TimeRangeModel*)initWithDataSource:(NSDictionary*)dict;

@end
