//
//  CRM_Approval.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/30.
//  Copyright © 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface CRM_Approval : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *runId;
@property (strong, nonatomic) NSNumber *approveStatus;
@property (copy, nonatomic) NSString *flowName;
@property (copy, nonatomic) NSString *approveNo;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) User *creator;
@property (strong, nonatomic) User *approver;
@property (strong, nonatomic) NSMutableArray *ccUsersArray;
@end