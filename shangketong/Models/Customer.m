//
//  Customer.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Customer.h"

@implementation Customer

- (instancetype)copyWithZone:(NSZone *)zone {
    Customer *customer = [[self class] allocWithZone:zone];
    customer.id = [_id copy];
    customer.focus = [_focus copy];
    customer.createTime = [_createTime copy];
    customer.expireDate = [_expireDate copy];
    customer.name = [_name copy];
    customer.statusDesc = [_statusDesc copy];
    customer.position = [_position copy];
    customer.phone = [_phone copy];
    return customer;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _id = [aDecoder decodeObjectForKey:@"id"];
        _focus = [aDecoder decodeObjectForKey:@"focus"];
        _createTime = [aDecoder decodeObjectForKey:@"createTime"];
        _expireDate = [aDecoder decodeObjectForKey:@"expireDate"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _statusDesc = [aDecoder decodeObjectForKey:@"statusDesc"];
        _position = [aDecoder decodeObjectForKey:@"position"];
        _phone = [aDecoder decodeObjectForKey:@"phone"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_focus forKey:@"focus"];
    [aCoder encodeObject:_createTime forKey:@"createTime"];
    [aCoder encodeObject:_expireDate forKey:@"expireDate"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_statusDesc forKey:@"statusDesc"];
    [aCoder encodeObject:_position forKey:@"position"];
    [aCoder encodeObject:_phone forKey:@"phone"];
}

+ (NSString*)keyName {
    return @"name";
}

#pragma mark - XLFormOptionObject
- (NSString*)formDisplayText {
    return _name;
}

- (id)formValue {
    return _id;
}
@end