//
//  FilterValue.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FilterValue.h"
#import "AddressBook.h"

@implementation FilterValue

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _id = [aDecoder decodeObjectForKey:@"id"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _icon = [aDecoder decodeObjectForKey:@"icon"];
        _isSelected = [[aDecoder decodeObjectForKey:@"isSelected"] boolValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_icon forKey:@"icon"];
    [aCoder encodeObject:@(_isSelected) forKey:@"isSelected"];
}

- (FilterValue*)initWithModel:(AddressBook *)item {
    self = [super init];
    if (self) {
        self.id = [NSString stringWithFormat:@"%@", item.id];
        self.icon = item.icon;
        self.name = item.name;
        self.isSelected = item.isSelected;
    }
    return self;
}

+ (FilterValue*)initWithModel:(AddressBook *)item {
    FilterValue *value = [[FilterValue alloc] initWithModel:item];
    return value;
}
@end
