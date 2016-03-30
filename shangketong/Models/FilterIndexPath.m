//
//  FilterIndexPath.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FilterIndexPath.h"

@implementation FilterIndexPath

- (instancetype)initIndexPathWithType:(FilterType)type row:(NSInteger)row {
    self = [super init];
    if (self) {
        self.type = type;
        self.row = row;
    }
    return self;
}

+ (instancetype)initIndexPathWithType:(FilterType)type row:(NSInteger)row {
    FilterIndexPath *indexPath = [[FilterIndexPath alloc] initIndexPathWithType:type row:row];
    return indexPath;
}

- (instancetype)initIndexPathWithType:(FilterType)type row:(NSInteger)row item:(NSInteger)item {
    self = [super init];
    if (self) {
        self.type = type;
        self.row = row;
        self.item = item;
    }
    return self;
}

+ (instancetype)initIndexPathWithType:(FilterType)type row:(NSInteger)row item:(NSInteger)item {
    FilterIndexPath *indexPath = [[FilterIndexPath alloc] initIndexPathWithType:type row:row item:item];
    return indexPath;
}

@end
