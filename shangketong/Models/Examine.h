//
//  Examine.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "BusinessFrom.h"
#import "ColumnModel.h"
#import "ColumnSelectModel.h"

@interface Examine : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *customId;
@property (strong, nonatomic) NSNumber *status;
@property (strong, nonatomic) NSNumber *approveStatus;
@property (strong, nonatomic) NSDate *reviewTime;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *approveNo;
@property (copy, nonatomic) NSString *remark;

@property (strong, nonatomic) NSMutableArray *columnListArray;
@property (strong, nonatomic) NSMutableArray *ccUsersArray;
@property (strong, nonatomic) User *applyUser;
@property (strong, nonatomic) User *reviewUsers;
@property (strong, nonatomic) BusinessFrom *from;       // 关联业务
@end
