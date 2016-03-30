//
//  AddressBookGroup.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressBookGroup.h"

@implementation AddressBookGroup

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _groupName = [aDecoder decodeObjectForKey:@"groupName"];
        _groupItems = [aDecoder decodeObjectForKey:@"groupItems"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.groupName forKey:@"groupName"];
    [aCoder encodeObject:self.groupItems forKey:@"groupItems"];
}

- (AddressBookGroup*)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        self.groupName = name;
        self.groupItems = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

+ (AddressBookGroup*)initWithName:(NSString *)name {
    AddressBookGroup *group = [[AddressBookGroup alloc] initWithName:name];
    return group;
}
@end
