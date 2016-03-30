//
//  SaleLead.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SaleLead.h"

@implementation SaleLead

+ (SaleLead*)initWithDataSource:(NSDictionary *)dict
{
    SaleLead *saleLead = [[SaleLead alloc] initWithDataSource:dict];
    return saleLead;
}

- (SaleLead*)initWithDataSource:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
        if ([dict objectForKey:@"id"]) {
            _m_uid = [dict safeObjectForKey:@"id"];
        }
        
        if ([dict objectForKey:@"name"]) {
            _m_name = [dict safeObjectForKey:@"name"];
        }
        
        if ([dict objectForKey:@"ownerId"]) {
            _m_ownerId = [dict safeObjectForKey:@"ownerId"];
        }
        
        if ([dict objectForKey:@"pinyin"]) {
            _m_pinyin = [dict safeObjectForKey:@"pinyin"];
        }
        
        if ([dict objectForKey:@"companyName"]) {
            _m_companyName = [dict safeObjectForKey:@"companyName"];
        }
        if ([dict objectForKey:@"status"]) {
            _m_status = [[dict safeObjectForKey:@"status"] integerValue];
        }
        
        if ([dict objectForKey:@"mobile"]) {
            _m_mobile = [dict safeObjectForKey:@"mobile"];
        }
        
        if ([dict objectForKey:@"phone"]) {
            _m_phone = [dict safeObjectForKey:@"phone"];
        }
        
        if ([dict objectForKey:@"post"]) {
            _m_post = [dict safeObjectForKey:@"post"];
        }
        
        if ([dict objectForKey:@"address"]) {
            _m_address = [dict safeObjectForKey:@"address"];
        }
        
        if ([dict objectForKey:@"highSeaStatus"]) {
            _m_highSeaStatus = [[dict safeObjectForKey:@"highSeaStatus"] integerValue];
        }
        
        if ([dict objectForKey:@"expireTime"]) {
            _m_expireTime = [dict safeObjectForKey:@"expireTime"];
        }
        
        if ([dict objectForKey:@"claimTime"]) {
            _m_claimTime = [dict safeObjectForKey:@"claimTime"];
        }
        
        if ([dict objectForKey:@"createdAt"]) {
            _m_createdAt = [dict safeObjectForKey:@"createdAt"];
        }
        
        if ([dict objectForKey:@"recentActivityRecordTime"]) {
            _m_recentActivityRecordTime = [dict safeObjectForKey:@"recentActivityRecordTime"];
        }
        
        if ([dict objectForKey:@"delFlg"]) {
            _m_delFlg = [[dict safeObjectForKey:@"delFlg"] integerValue];
        }
        
    }
    return self;
}

@end
