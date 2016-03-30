//
//  IndexCondition.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "IndexCondition.h"

@implementation IndexCondition

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _id = [aDecoder decodeObjectForKey:@"id"];
        _itemCount = [aDecoder decodeObjectForKey:@"itemCount"];
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_itemCount forKey:@"itemCount"];
    [aCoder encodeObject:_name forKey:@"name"];
}

- (instancetype)initWithId:(NSNumber *)mID name:(NSString *)name {
    self = [super init];
    if (self) {
        _id = mID;
        _name = name;
    }
    return self;
}

+ (instancetype)initWithId:(NSNumber *)mID name:(NSString *)name {
    IndexCondition *item = [[IndexCondition alloc] initWithId:mID name:name];
    return item;
}
@end
