//
//  SKTIndexPath.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SKTIndexPath.h"

@implementation SKTIndexPath

- (instancetype)initIndexPathWithType:(SKTIndexPathType)type andRow:(NSInteger)row {
    self = [super init];
    if (self) {
        _type = type;
        _row = row;
        _item = -1;
    }
    return self;
}

- (instancetype)initIndexPathWithType:(SKTIndexPathType)type andRow:(NSInteger)row andItem:(NSInteger)item {
    self = [super init];
    if (self) {
        _type = type;
        _row = row;
        _item = item;
    }
    return self;
}

+ (instancetype)initIndexPathWithType:(SKTIndexPathType)type andRow:(NSInteger)row {
    SKTIndexPath *indexPath = [[SKTIndexPath alloc] initIndexPathWithType:type andRow:row];
    return indexPath;
}

+ (instancetype)initIndexPathWithType:(SKTIndexPathType)type andRow:(NSInteger)row andItem:(NSInteger)item {
    SKTIndexPath *indexPath = [[SKTIndexPath alloc] initIndexPathWithType:type andRow:row andItem:item];
    return indexPath;
}
@end
