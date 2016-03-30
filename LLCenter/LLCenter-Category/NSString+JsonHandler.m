//
//  NSString+JsonHandler.m
//  lianluozhongxin
//
//  Created by Vescky on 14-7-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "NSString+JsonHandler.h"

@implementation NSString (JsonHandler)

- (id)toJsonValue {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"#### Error--AppsEngine->toValue:%@",error);
    }
    if (!resultDict) {
        resultDict = [[NSDictionary alloc] init];
    }
    
    return resultDict;
}

@end
