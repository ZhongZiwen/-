//
//  WorkReportItem.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WorkReportItem.h"

@implementation WorkReportItem

- (WorkReportItem*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        
        self.m_reportID = [[dict safeObjectForKey:@"id"] integerValue];
        self.m_reportType = [dict safeObjectForKey:@"type"];
        if ([_m_reportType  isEqualToString:@"dayReport"]) {
            self.m_reportTypeIndex = 0;
            self.m_reportTypeName = @"日报";
        }else if ([_m_reportType isEqualToString:@"weekReport"]) {
            self.m_reportTypeIndex = 1;
            self.m_reportTypeName = @"周报";
        }else  if ([_m_reportType isEqualToString:@"monthReport"]){
            self.m_reportTypeIndex = 2;
            self.m_reportTypeName = @"月报";
        }
        self.m_reportTime = [dict safeObjectForKey:@"reportTime"];
        self.m_createAt = [dict safeObjectForKey:@"createAt"];
        self.m_paperStatus = [[dict safeObjectForKey:@"paperStatus"] boolValue];
        self.m_readStatus = [[dict safeObjectForKey:@"readStatus"] boolValue];
        self.m_creatorIcon = [[dict objectForKey:@"creator"] safeObjectForKey:@"icon"];
        self.m_creatorId = [[dict objectForKey:@"creator"] safeObjectForKey:@"id"];
        self.m_creatorName = [[dict objectForKey:@"creator"] safeObjectForKey:@"name"];
        
        self.m_reveiwerId = @"";
        NSDictionary *reveiwer = nil;
        if ([dict objectForKey:@"reveiwer"]) {
            reveiwer = [dict objectForKey:@"reveiwer"];
        }
        
        if (reveiwer && (id)reveiwer != [NSNull null]) {
            self.m_reveiwerId = [reveiwer safeObjectForKey:@"id"];
        }
    }
    return self;
}

+ (WorkReportItem*)initWithDictionary:(NSDictionary *)dict {
    WorkReportItem *item = [[WorkReportItem alloc] initWithDictionary:dict];
    return item;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _m_reportID = [[aDecoder decodeObjectForKey:@"m_reportID"] integerValue];
        _m_reportType = [aDecoder decodeObjectForKey:@"m_reportType"];
        _m_reportTypeName = [aDecoder decodeObjectForKey:@"m_reportTypeName"];
        _m_reportTypeIndex = [[aDecoder decodeObjectForKey:@"m_reportTypeIndex"] integerValue];
        _m_reportTime = [aDecoder decodeObjectForKey:@"m_reportTime"];
        _m_createAt = [aDecoder decodeObjectForKey:@"m_createAt"];
        _m_paperStatus = [[aDecoder decodeObjectForKey:@"m_paperStatus"] boolValue];
        _m_readStatus = [[aDecoder decodeObjectForKey:@"m_readStatus"] boolValue];
        _m_creatorIcon = [aDecoder decodeObjectForKey:@"m_creatorIcon"];
        _m_creatorId = [aDecoder decodeObjectForKey:@"m_creatorId"];
        _m_creatorName = [aDecoder decodeObjectForKey:@"m_creatorName"];
        _m_reveiwerId = [aDecoder decodeObjectForKey:@"m_reveiwerId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_m_reportID) forKey:@"m_reportID"];
    [aCoder encodeObject:_m_reportType forKey:@"m_reportType"];
    [aCoder encodeObject:_m_reportTypeName forKey:@"m_reportTypeName"];
    [aCoder encodeObject:@(_m_reportTypeIndex) forKey:@"m_reportTypeIndex"];
    [aCoder encodeObject:_m_reportTime forKey:@"m_reportTime"];
    [aCoder encodeObject:_m_createAt forKey:@"m_createAt"];
    [aCoder encodeObject:@(_m_paperStatus) forKey:@"m_paperStatus"];
    [aCoder encodeObject:@(_m_readStatus) forKey:@"m_readStatus"];
    [aCoder encodeObject:_m_creatorIcon forKey:@"m_creatorIcon"];
    [aCoder encodeObject:_m_creatorId forKey:@"m_creatorId"];
    [aCoder encodeObject:_m_creatorName forKey:@"m_creatorName"];
    [aCoder encodeObject:_m_reveiwerId forKey:@"m_reveiwerId"];
}

@end
