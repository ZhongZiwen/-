//
//  Filter.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Filter.h"

@implementation Filter

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _id = [aDecoder decodeObjectForKey:@"id"];
        _itemName = [aDecoder decodeObjectForKey:@"itemName"];
        _searchType = [aDecoder decodeObjectForKey:@"searchType"];
        _columnType = [aDecoder decodeObjectForKey:@"columnType"];
        _showWhenInit = [aDecoder decodeObjectForKey:@"showWhenInit"];
        _valuesArray = [aDecoder decodeObjectForKey:@"valuesArray"];
        _isCondition = [[aDecoder decodeObjectForKey:@"isCondition"] boolValue];
        _isExpand = [[aDecoder decodeObjectForKey:@"isExpand"] boolValue];
        _leftValue = [[aDecoder decodeObjectForKey:@"leftValue"] integerValue];
        _rightValue = [[aDecoder decodeObjectForKey:@"rightValue"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_itemName forKey:@"itemName"];
    [aCoder encodeObject:_searchType forKey:@"searchType"];
    [aCoder encodeObject:_columnType forKey:@"columnType"];
    [aCoder encodeObject:_showWhenInit forKey:@"showWhenInit"];
    [aCoder encodeObject:_valuesArray forKey:@"valuesArray"];
    [aCoder encodeObject:@(_isCondition) forKey:@"isCondition"];
    [aCoder encodeObject:@(_isExpand) forKey:@"isExpand"];
    [aCoder encodeObject:@(_leftValue) forKey:@"leftValue"];
    [aCoder encodeObject:@(_rightValue) forKey:@"rightValue"];
}

- (id)init {
    self = [super init];
    if (self) {
        _valuesArray = [[NSMutableArray alloc] initWithCapacity:0];
        _leftValue = 0;
        _rightValue = 5;
    }
    return self;
}
@end
