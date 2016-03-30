//
//  SKTCondition.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SKTCondition.h"
#import "SKTFilterValue.h"

@implementation SKTCondition

- (SKTCondition*)initWithItemId:(NSString *)itemId andItemName:(NSString *)itemName andType:(NSInteger)searchType andValue:(SKTFilterValue *)filterValue {
    self = [super init];
    if (self) {
        self.m_itemId = itemId;
        self.m_itemName = itemName;
        self.m_itemType = searchType;
        self.m_name = filterValue.m_name;
        self.m_id = filterValue.m_id;
        self.titleValue = filterValue;
        self.m_icon = filterValue.m_icon;
    }
    return self;
}

+ (SKTCondition*)initWithItemId:(NSString *)itemId andItemName:(NSString *)itemName andType:(NSInteger)searchType andValue:(SKTFilterValue *)filterValue {
    SKTCondition *condition = [[SKTCondition alloc] initWithItemId:itemId andItemName:itemName andType:searchType andValue:filterValue];
    return condition;
}
#pragma mark - NSCoding delege
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _m_itemId = [aDecoder decodeObjectForKey:@"m_itemId"];
        _m_itemName = [aDecoder decodeObjectForKey:@"m_itemName"];
        _m_itemType = [[aDecoder decodeObjectForKey:@"m_itemType"] integerValue];
        _m_id = [aDecoder decodeObjectForKey:@"m_id"];
        _m_name = [aDecoder decodeObjectForKey:@"m_name"];
        _m_icon = [aDecoder decodeObjectForKey:@"m_icon"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_m_itemId forKey:@"m_itemId"];
    [aCoder encodeObject:_m_itemName forKey:@"m_itemName"];
    [aCoder encodeObject:@(_m_itemType) forKey:@"m_itemType"];
    [aCoder encodeObject:_m_id forKey:@"m_id"];
    [aCoder encodeObject:_m_name forKey:@"m_name"];
    [aCoder encodeObject:_m_icon forKey:@"m_icon"];
}
@end
