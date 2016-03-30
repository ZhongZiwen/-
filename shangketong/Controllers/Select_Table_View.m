//
//  Select_Table_View.m
//  Select_TableView
//
//  Created by 蒋 on 15/9/24.
//  Copyright (c) 2015年 蒋. All rights reserved.
//

#import "Select_Table_View.h"

@implementation Select_Table_View
{
    NSMutableArray *dataArray;
}
- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray *)array{
    self = [super initWithFrame:frame];
    if (self) {
        //初始化dataArray  并 赋值
        dataArray = [NSMutableArray arrayWithArray:array];
        //添加一个View 做为背景
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeView:)];
        self.bgView = [[UIView alloc] initWithFrame:frame];
        [self.bgView addGestureRecognizer:tap];
        [self addSubview:self.bgView];
        
        [self refushTableView];
        }
    return self;
}
- (void)removeView:(UITapGestureRecognizer *)tap {
    if (_RemoveViewBlock) {
        _RemoveViewBlock();
    }
}
- (void)refushTableView{
    //刷新tableView的Frame, 根据数据的个数对高度进行限制
    CGFloat hight = 0.;
    if (dataArray.count > 5) {
        hight = 5 * 44;
    } else {
        hight = dataArray.count * 44;
    }
    self.tableViewSelect.frame = CGRectMake(_bgView.frame.size.width / 2, 74, _bgView.frame.size.width / 2 - 10, hight);
    if (dataArray.count > 5) {
        self.tableViewSelect.scrollEnabled = YES;
    } else {
        self.tableViewSelect.scrollEnabled = NO;
    }

}
- (UITableView *)tableViewSelect {
    if (!_tableViewSelect) {
        _tableViewSelect = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableViewSelect.tag = 200;
        _tableViewSelect.delegate = self;
        _tableViewSelect.dataSource = self;
        [self addSubview:_tableViewSelect];
        [self bringSubviewToFront:_tableViewSelect];
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableViewSelect setTableFooterView:v];
    }
    return _tableViewSelect;
}

#pragma mark - table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = dataArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_tableViewSelect selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];

    if (indexPath.row == 4 && indexPath.row == (dataArray.count - 1)) {
        [dataArray removeLastObject];
        [dataArray addObject:@"22"];
        [dataArray addObject: @"33"];
        [self refushTableView];
        [_tableViewSelect reloadData];
    } else {
        if (_BackIndexBlock) {
            _BackIndexBlock(indexPath.row);
        }
    }
}
@end
