//
//  Schedule.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScheduleType.h"

@interface Schedule : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (copy, nonatomic) NSString *name;
//@property (copy, nonatomic) NSString *description;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSDate *updatedAt;
@property (strong, nonatomic) NSDate *reminderTime;
@property (strong, nonatomic) NSNumber *isAllDay;
@property (strong, nonatomic) NSNumber *isRepeat;
@property (strong, nonatomic) NSNumber *repeatType;
@property (strong, nonatomic) NSNumber *repeatEndType;
@property (strong, nonatomic) NSDate *repeatEndTime;
@property (strong, nonatomic) NSNumber *reminderType;
@property (strong, nonatomic) NSNumber *myState;        // 当前登入用户对日程的状态 10:你可以接受这个日程（OA详情列表和详情用）
@property (strong, nonatomic) NSNumber *createdBy;
@property (strong, nonatomic) NSNumber *updatedBy;
@property (strong, nonatomic) NSNumber *isPrivate;
@property (strong, nonatomic) ScheduleType *colorType;
@end