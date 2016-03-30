//
//  NSObject+JsonHandler.m
//  lianluozhongxin
//
//  Created by Vescky on 14-7-15.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "NSObject+JsonHandler.h"

@implementation NSObject (JsonHandler)

- (NSString*)toJsonString {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"#### Error--AppsEngine->toValue:%@",error);
    }
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return str;
}

@end
