//
//  Approval.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Approval.h"
#import "CommonFuntion.h"

@implementation Approval

- (Approval*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.m_approveNo = [NSString stringWithFormat:@"%lld", [dict[@"approveNo"] longLongValue]];
        self.m_id = [dict[@"id"] integerValue];
        self.m_runId = [[dict safeObjectForKey:@"runId"] integerValue];
        self.m_approveStatus = [dict[@"approveStatus"] integerValue];
        self.m_flowName = [dict safeObjectForKey:@"flowName"];
        self.m_createdTime = [dict safeObjectForKey:@"createdAt"];
        self.m_reviewTime = [dict safeObjectForKey:@"reviewTime"];
        if ([CommonFuntion checkNullForValue:[dict objectForKey:@"approver"]]) {
            self.m_approverName = [[dict objectForKey:@"approver"] safeObjectForKey:@"name"];
            self.m_approverId = [[[dict objectForKey:@"approver"] safeObjectForKey:@"id"] integerValue];
//            self.m_approverIcon = [[dict objectForKey:@"approver"] safeObjectForKey:@"icon"];
        }
        if ([CommonFuntion checkNullForValue:[dict objectForKey:@"creator"]]) {
//            self.m_approverName = [[dict objectForKey:@"creator"] safeObjectForKey:@"name"];
//            self.m_approverId = [[[dict objectForKey:@"creator"] safeObjectForKey:@"id"] integerValue];
            self.m_approverIcon = [[dict objectForKey:@"creator"] safeObjectForKey:@"icon"];
        }

    }
    return self;
}

+ (Approval*)initWithDictionary:(NSDictionary *)dict {
    Approval *approval = [[Approval alloc] initWithDictionary:dict];
    return approval;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _m_id = [[aDecoder decodeObjectForKey:@"m_id"] integerValue];
        _m_runId = [[aDecoder decodeObjectForKey:@"m_runId"] integerValue];
        _m_approveStatus = [[aDecoder decodeObjectForKey:@"m_approveStatus"] integerValue];
        _m_flowName = [aDecoder decodeObjectForKey:@"m_flowName"];
        _m_createdTime = [aDecoder decodeObjectForKey:@"m_createdTime"];
        _m_reviewTime = [aDecoder decodeObjectForKey:@"m_reviewTime"];
        _m_approverName = [aDecoder decodeObjectForKey:@"m_approverName"];
        _m_approverId = [[aDecoder decodeObjectForKey:@"m_approverId"] integerValue];
        _m_approverIcon = [aDecoder decodeObjectForKey:@"m_approverIcon"];
        _m_approveNo = [aDecoder decodeObjectForKey:@"m_approveNo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_m_id) forKey:@"m_id"];
    [aCoder encodeObject:@(_m_runId) forKey:@"m_runId"];
    [aCoder encodeObject:@(_m_approveStatus) forKey:@"m_approveStatus"];
    [aCoder encodeObject:_m_flowName forKey:@"m_flowName"];
    [aCoder encodeObject:_m_createdTime forKey:@"m_createdTime"];
    [aCoder encodeObject:_m_createdTime forKey:@"m_reviewTime"];
    
    [aCoder encodeObject:_m_approverName forKey:@"m_approverName"];
    [aCoder encodeObject:@(_m_approverId) forKey:@"m_approverId"];
    [aCoder encodeObject:_m_approverIcon forKey:@"m_approverIcon"];
    [aCoder encodeObject:_m_approveNo forKey:@"m_approveNo"];
}

@end
