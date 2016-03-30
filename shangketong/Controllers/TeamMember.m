//
//  TeamMember.m
//  shangketong
//
//  Created by sungoin-zjp on 15-9-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TeamMember.h"

@implementation TeamMember

- (TeamMember*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.m_id = [dict safeObjectForKey:@"id"] ;
        self.m_name = [dict safeObjectForKey:@"name"];
        self.m_icon = [dict safeObjectForKey:@"icon"];
       
    }
    return self;
}

+ (TeamMember*)initWithDictionary:(NSDictionary *)dict {
    TeamMember *item = [[TeamMember alloc] initWithDictionary:dict];
    return item;
}

@end
