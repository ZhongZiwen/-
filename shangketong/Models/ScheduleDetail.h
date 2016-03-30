//
//  ScheduleDetail.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "ScheduleType.h"
#import "BusinessFrom.h"

@interface ScheduleDetail : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *createdBy;
@property (strong, nonatomic) NSNumber *updatedBy;
@property (strong, nonatomic) NSNumber *isAllDay;
@property (strong, nonatomic) NSNumber *isRepeat;
@property (strong, nonatomic) NSNumber *repeatType;
@property (strong, nonatomic) NSNumber *reminderType;
@property (strong, nonatomic) NSNumber *isPrivate;
@property (strong, nonatomic) NSNumber *typeId;
@property (strong, nonatomic) NSNumber *objectId;

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *descrip;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDate *reminderTime;
@property (strong, nonatomic) NSNumber *repeatEndType;
@property (copy, nonatomic) NSString *repeatEndTime;
@property (strong, nonatomic) NSDate *createdAt;
@property (copy, nonatomic) NSString *createdName;
@property (strong, nonatomic) NSDate *updatedAt;
@property (copy, nonatomic) NSString *objectName;

@property (strong, nonatomic) NSMutableArray *waitingMembersArray;
@property (strong, nonatomic) NSMutableArray *acceptMembersArray;
@property (strong, nonatomic) NSMutableArray *rejectMembersArray;
@property (strong, nonatomic) NSMutableArray *filesArray;
@property (strong, nonatomic) ScheduleType *colorType;
@property (strong, nonatomic) BusinessFrom *from;

@property (strong, nonatomic) XLFormDescriptor *formDescriptor;

- (void)reloadXLForm;
@end