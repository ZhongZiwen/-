//
//  SKTYearDateFormatter.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SKTYearDateFormatter.h"

@implementation SKTYearDateFormatter

+ (SKTYearDateFormatter*)sharedFormatter {
    static dispatch_once_t onceToken;
    static SKTYearDateFormatter *formatter = nil;
    dispatch_once(&onceToken, ^{
        formatter = [[SKTYearDateFormatter alloc] init];
    });
    return formatter;
}

@end
