//
//  PresentItem.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PresentItem.h"

@implementation PresentItem

- (PresentItem*)initWithTitle:(NSString *)titleStr {
    self = [super init];
    if (self) {
        self.m_title = titleStr;
        self.isSelected = NO;   // 默认为不选中
    }
    return self;
}

+ (PresentItem*)initWithTitle:(NSString *)titleStr {
    PresentItem *item = [[PresentItem alloc] initWithTitle:titleStr];
    return item;
}
@end
