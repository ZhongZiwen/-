//
//  ReleasePrivacyItem.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ReleasePrivacyItem.h"

@implementation ReleasePrivacyItem

- (ReleasePrivacyItem*)initWithIndex:(NSInteger)index andTitle:(NSString *)string {
    self = [super init];
    if (self) {
        _indexRow = index;
        _privacyString = string;
    }
    return self;
}

+ (ReleasePrivacyItem*)initWithIndex:(NSInteger)index andTitle:(NSString *)string {
    ReleasePrivacyItem *item = [[ReleasePrivacyItem alloc] initWithIndex:index andTitle:string];
    return item;
}

@end
