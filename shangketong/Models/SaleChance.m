//
//  SaleChance.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SaleChance.h"

@implementation SaleChance

- (instancetype)copyWithZone:(NSZone *)zone {
    SaleChance *item = [[self class] allocWithZone:zone];
    item.id = [_id copy];
    item.focus = [_focus copy];
    item.name = [_name copy];
    item.customerName = [_customerName copy];
    item.money = [_money copy];
    item.ownerName = [_ownerName copy];
    return item;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _id = [aDecoder decodeObjectForKey:@"id"];
        _focus = [aDecoder decodeObjectForKey:@"focus"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _customerName = [aDecoder decodeObjectForKey:@"customerName"];
        _money = [aDecoder decodeObjectForKey:@"money"];
        _ownerName = [aDecoder decodeObjectForKey:@"ownerName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_focus forKey:@"focus"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_customerName forKey:@"customerName"];
    [aCoder encodeObject:_money forKey:@"money"];
    [aCoder encodeObject:_ownerName forKey:@"ownerName"];
}

+ (NSString*)keyName {
    return @"name";
}
@end