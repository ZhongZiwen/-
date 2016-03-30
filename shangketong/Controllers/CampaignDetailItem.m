//
//  CampaignDetailItem.m
//  shangketong
//
//  Created by sungoin-zjp on 15-9-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CampaignDetailItem.h"

@implementation CampaignDetailItem

- (CampaignDetailItem*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.m_columnType = [[dict safeObjectForKey:@"columnType"] integerValue];
        self.m_name = [dict safeObjectForKey:@"name"];
        self.m_propertyName = [dict safeObjectForKey:@"propertyName"];
        self.m_object = [dict safeObjectForKey:@"object"];
        self.m_result = [dict safeObjectForKey:@"result"];
        self.m_required = [[dict safeObjectForKey:@"required"] integerValue];
        if (self.m_columnType == 3 || self.m_columnType == 4) {
            self.m_selectArray = [[NSArray alloc] initWithArray:dict[@"select"]];
        }
    }
    return self;
}

+ (CampaignDetailItem*)initWithDictionary:(NSDictionary *)dict {
    CampaignDetailItem *item = [[CampaignDetailItem alloc] initWithDictionary:dict];
    return item;
}

@end
