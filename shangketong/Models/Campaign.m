//
//  Campaign.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Campaign.h"

@implementation Campaign

+ (Campaign*)initWithDictionary:(NSDictionary *)dict
{
    Campaign *campaign = [[Campaign alloc] initWithDataSource:dict];
    return campaign;
}

- (Campaign*)initWithDataSource:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
    
        if ([dict objectForKey:@"id"]) {
            _m_uid = [dict safeObjectForKey:@"id"];
        }
        if ([dict objectForKey:@"name"]) {
            _m_name = [dict safeObjectForKey:@"name"];
        }
        if ([dict objectForKey:@"focus"]) {
            _m_focus = [dict safeObjectForKey:@"focus"];
        }
    }
    return self;
}


- (NSDictionary *) encodedCampaign
{
    return [NSDictionary dictionaryWithObjectsAndKeys:self.m_uid, @"id",self.m_name,@"name",self.m_focus,@"focus",nil];
}

@end
