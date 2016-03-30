//
//  User.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "User.h"

@implementation User

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.icon forKey:@"icon"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.company forKey:@"companyName"];
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.serverTime forKey:@"serverTime"];
    [aCoder encodeObject:self.pinyin forKey:@"pinyin"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self.icon = [aDecoder decodeObjectForKey:@"icon"];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.company = [aDecoder decodeObjectForKey:@"companyName"];
    self.id = [aDecoder decodeObjectForKey:@"id"];
    self.serverTime = [aDecoder decodeObjectForKey:@"serverTime"];
    self.pinyin = [aDecoder decodeObjectForKey:@"pinyin"];
    return self;
}
@end
