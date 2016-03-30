//
//  Stage.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Stage.h"

@implementation Stage

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _id = [aDecoder decodeObjectForKey:@"id"];
        _count = [aDecoder decodeObjectForKey:@"count"];
        _percent = [aDecoder decodeObjectForKey:@"percent"];
        _money = [aDecoder decodeObjectForKey:@"money"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _isShow = [[aDecoder decodeObjectForKey:@"isShow"] boolValue];
//        _opportunityArray = [aDecoder decodeObjectForKey:@"opportunityArray"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_count forKey:@"count"];
    [aCoder encodeObject:_percent forKey:@"percent"];
    [aCoder encodeObject:_money forKey:@"money"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:@(_isShow) forKey:@"isShow"];
//    [aCoder encodeObject:_opportunityArray forKey:@"opportunityArray"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _opportunityArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}
@end
