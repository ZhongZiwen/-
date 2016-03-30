//
//  SheetPhoneView.m
//  shangketong
//
//  Created by 蒋 on 16/1/20.
//  Copyright (c) 2016年 sungoin. All rights reserved.
//

#import "SheetPhoneView.h"
#import "SheetViewCell.h"

@implementation SheetPhoneView
{
    NSMutableArray *dataArray;
}
- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray *)array{
    self = [super initWithFrame:frame];
    if (self) {
        //初始化dataArray  并 赋值
        dataArray = [NSMutableArray arrayWithArray:array];
        CGFloat hight = array.count * 30;
        if (hight > kScreen_Height / 2) {
            hight = kScreen_Height / 2;
        }
        self.tableViewSelect.frame = CGRectMake(0, kScreen_Height - hight, kScreen_Width, hight);
        //添加一个View 做为背景
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeView:)];
        self.bgView = [[UIView alloc] initWithFrame:frame];
        [self.bgView addGestureRecognizer:tap];
        [self addSubview:self.bgView];
    }
    return self;
}
- (void)removeView:(UITapGestureRecognizer *)tap {
    if (_RemoveViewBlock) {
        _RemoveViewBlock();
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
    SheetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sheetViewCellIdentifier"];
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SheetViewCell" owner:self options:nil];
        cell = (SheetViewCell *)[array objectAtIndex:0];
        [cell awakeFromNib];

    }
    NSDictionary *dict = dataArray[indexPath.row];
    cell.nameLabel.text = [dict objectForKey:@"name"];
    cell.phoneLabel.text = [dict objectForKey:@"phone"];
    [cell.messageBtn addTarget:self action:@selector(messageAndCallBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cell.phoneBtn addTarget:self action:@selector(messageAndCallBtn:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_tableViewSelect selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}
- (void)messageAndCallBtn:(UIButton *)sender {
    
}
@end
