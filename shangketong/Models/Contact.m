//
//  Contact.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Contact.h"

@implementation Contact

- (instancetype)copyWithZone:(NSZone *)zone {
    // 实现自定义拷贝
    Contact *contact = [[self class] allocWithZone:zone];
    contact.id = [_id copy];
    contact.name = [_name copy];
    contact.job = [_job copy];
    contact.companyName = [_companyName copy];
    contact.position = [_position copy];
    contact.email = [_email copy];
    contact.mobile = [_mobile copy];
    contact.phone = [_phone copy];
    return contact;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _id = [aDecoder decodeObjectForKey:@"id"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _job = [aDecoder decodeObjectForKey:@"job"];
        _companyName = [aDecoder decodeObjectForKey:@"companyName"];
        _position = [aDecoder decodeObjectForKey:@"position"];
        _email = [aDecoder decodeObjectForKey:@"email"];
        _mobile = [aDecoder decodeObjectForKey:@"mobile"];
        _phone = [aDecoder decodeObjectForKey:@"phone"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_job forKey:@"job"];
    [aCoder encodeObject:_companyName forKey:@"companyName"];
    [aCoder encodeObject:_position forKey:@"position"];
    [aCoder encodeObject:_email forKey:@"email"];
    [aCoder encodeObject:_mobile forKey:@"mobile"];
    [aCoder encodeObject:_phone forKey:@"phone"];
}

+ (NSString*)keyName {
    return @"name";
}
@end
