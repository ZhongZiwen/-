//
//  ArrayDataSource.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ArrayDataSource.h"

@interface ArrayDataSource ()

@property (nonatomic, strong) NSArray *dataSourceArray;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;
@end

@implementation ArrayDataSource

- (id)initWithDataSource:(NSArray *)dataSource cellIdentifier:(NSString *)kCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)block
{
    self = [super init];
    if (self) {
        self.dataSourceArray = dataSource;
        self.cellIdentifier = kCellIdentifier;
        self.configureCellBlock = [block copy];
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.dataSourceArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSourceArray[section] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(cell, item);
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10.0f];
    return cell;
}

@end
