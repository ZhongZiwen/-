//
//  NSDictionary+safeObjectForKey.m
//  shangketong
//  针对 ”<null>“做处理
//  Created by sungoin-zjp on 15-7-20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "NSDictionary+safeObjectForKey.h"
#define checkNull(__X__)  (__X__) == [NSNull null] || (__X__) == nil ? @"" : [NSString stringWithFormat:@"%@", (__X__)]

@implementation NSDictionary (safeObjectForKey)

- (NSString *)safeObjectForKey:(id)key
{
    return checkNull([self objectForKey:key]);
}

-(BOOL)isObjectNil{
    if (self != nil && (id)self != [NSNull null]) {
        return NO;
    }
    return YES;
}

@end
