//
//  Task.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressBook.h"
#import "BusinessFrom.h"

@interface Task : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *priority;   // 重要度 0重要 1一般
@property (strong, nonatomic) NSNumber *isMine;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber *status;     // 1今天，2明天，3将来，4已过期，5待接受，6被拒绝，7已完成
@property (strong, nonatomic) NSNumber *taskStatus; // 1待接受，2未完成，3已完成，4已拒绝

@property (strong, nonatomic) AddressBook *owner;       // 责任人
@property (strong, nonatomic) AddressBook *createdBy;   // 创建人
@property (strong, nonatomic) BusinessFrom *from;       // 业务关联
@end