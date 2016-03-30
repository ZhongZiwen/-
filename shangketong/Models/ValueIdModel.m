//
//  ValueIdModel.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ValueIdModel.h"

@implementation ValueIdModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _id = [aDecoder decodeObjectForKey:@"id"];
        _value = [aDecoder decodeObjectForKey:@"value"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_value forKey:@"value"];
}

- (instancetype)initWithId:(NSString *)mId value:(NSString *)value {
    self = [super init];
    if (self) {
        _id = mId;
        _value = value;
    }
    return self;
}

+ (instancetype)initWithId:(NSString *)mId value:(NSString *)value {
    ValueIdModel *item = [[ValueIdModel alloc] initWithId:mId value:value];
    return item;
}
@end
