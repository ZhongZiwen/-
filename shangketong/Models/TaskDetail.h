//
//  TaskDetail.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "BusinessFrom.h"

@class XLFormDescriptor;

@interface TaskDetail : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSNumber *status;
@property (strong, nonatomic) NSNumber *taskStatus;
@property (strong, nonatomic) NSNumber *priority;
@property (strong, nonatomic) NSNumber *isMine;
@property (strong, nonatomic) NSNumber *remind;
@property (copy, nonatomic) NSString *descrip;
@property (copy, nonatomic) NSString *reason;

@property (strong, nonatomic) NSMutableArray *membersArray;
@property (strong, nonatomic) NSMutableArray *filesArray;
@property (strong, nonatomic) User *owner;
@property (strong, nonatomic) User *createdBy;
@property (strong, nonatomic) BusinessFrom *from;

@property (strong, nonatomic) XLFormDescriptor *formDescriptor;

- (void)reloadXLForm;
@end