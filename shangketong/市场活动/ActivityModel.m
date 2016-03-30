//
//  ActivityModel.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityModel.h"

@implementation ActivityModel

- (instancetype)copyWithZone:(NSZone *)zone {
    ActivityModel *item = [[self class] allocWithZone:zone];
    item.id = [_id copy];
    item.name = [_name copy];
    item.focus = [_focus copy];
    item.pinyin = [_pinyin copy];
    return item;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _id = [aDecoder decodeObjectForKey:@"id"];
        _focus = [aDecoder decodeObjectForKey:@"focus"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _pinyin = [aDecoder decodeObjectForKey:@"pinyin"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_focus forKey:@"focus"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_pinyin forKey:@"pinyin"];
}

+ (NSString*)keyName {
    return @"name";
}
@end
