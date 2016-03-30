//
//  Lead.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Lead.h"

@implementation Lead

- (instancetype)copyWithZone:(NSZone *)zone {
    Lead *lead = [[self class] allocWithZone:zone];
    lead.id = [_id copy];
    lead.name = [_name copy];
    lead.companyName = [_companyName copy];
    lead.position = [_position copy];
    lead.phone = [_phone copy];
    lead.mobile = [_mobile copy];
    lead.email = [_email copy];
    lead.duty = [_duty copy];
    lead.ownerName = [_ownerName copy];
    lead.createTime = [_createTime copy];
    lead.expireDate = [_expireDate copy];
    return lead;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _id = [aDecoder decodeObjectForKey:@"id"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _companyName = [aDecoder decodeObjectForKey:@"companyName"];
        _position = [aDecoder decodeObjectForKey:@"position"];
        _phone = [aDecoder decodeObjectForKey:@"phone"];
        _mobile = [aDecoder decodeObjectForKey:@"mobile"];
        _email = [aDecoder decodeObjectForKey:@"email"];
        _duty = [aDecoder decodeObjectForKey:@"duty"];
        _ownerName = [aDecoder decodeObjectForKey:@"ownerName"];
        _createTime = [aDecoder decodeObjectForKey:@"createTime"];
        _expireDate = [aDecoder decodeObjectForKey:@"expireDate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_companyName forKey:@"companyName"];
    [aCoder encodeObject:_position forKey:@"position"];
    [aCoder encodeObject:_phone forKey:@"phone"];
    [aCoder encodeObject:_mobile forKey:@"mobile"];
    [aCoder encodeObject:_email forKey:@"email"];
    [aCoder encodeObject:_duty forKey:@"duty"];
    [aCoder encodeObject:_ownerName forKey:@"ownerName"];
    [aCoder encodeObject:_createTime forKey:@"createTime"];
    [aCoder encodeObject:_expireDate forKey:@"expireDate"];
}

+ (NSString*)keyName {
    return @"name";
}
@end
