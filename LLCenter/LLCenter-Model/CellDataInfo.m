//
//  CellDataInfo.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-17.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "CellDataInfo.h"

@implementation CellDataInfo

@synthesize cellDataInfo,expandable,expanded,extra;

- (id)initWithCellDataInfo:(NSDictionary*)_cInfo {
    CellDataInfo *c = [[CellDataInfo alloc] init];
    c.cellDataInfo = _cInfo;
    c.expandable = NO;
    c.expanded = NO;
    return c;
}

- (id)initWithCellDataInfo:(NSDictionary*)_cInfo expandable:(bool)_expandale {
    CellDataInfo *c = [[CellDataInfo alloc] init];
    c.cellDataInfo = _cInfo;
    c.expandable = _expandale;
    c.expanded = NO;
    return c;
}

- (id)initWithCellDataInfo:(NSDictionary*)_cInfo expandable:(bool)_expandale expanded:(bool)_expanded {
    CellDataInfo *c = [[CellDataInfo alloc] init];
    c.cellDataInfo = _cInfo;
    c.expandable = _expandale;
    c.expanded = _expanded;
    return c;
}

@end
