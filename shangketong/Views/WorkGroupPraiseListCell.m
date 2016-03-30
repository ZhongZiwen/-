//
//  WorkGroupPraiseListCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WorkGroupPraiseListCell.h"
#import "WrokGroupPraiseCell.h"

@interface WorkGroupPraiseListCell ()<UITableViewDelegate,UITableViewDataSource> {
    
}
@end

@implementation WorkGroupPraiseListCell

- (void)awakeFromNib {
    // Initialization code
    [self initTableviewPraise];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(NSArray *)array indexPath:(NSIndexPath *)indexPath{
    self.arrayPraise = array;
    [self.tableviewPraise reloadData];
    if ([self.arrayPraise count] < 8) {
        self.tableviewPraise.scrollEnabled = NO;
    }else{
        self.tableviewPraise.scrollEnabled = YES;
    }
}

#pragma mark - 初始化点赞tablview
-(void)initTableviewPraise{
    NSLog(@"");
    self.tableviewPraise.frame = CGRectMake(0, 40, kScreen_Width,40);
    self.tableviewPraise.backgroundColor = [UIColor clearColor];
    //    tableviewPraise.backgroundView = nil;
    
    [self.tableviewPraise.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    self.tableviewPraise.transform = CGAffineTransformMakeRotation(M_PI/-2);
    self.tableviewPraise.showsVerticalScrollIndicator = NO;
//    self.tableviewPraise.frame = CGRectMake(0,0,50, kScreen_Width);
    self.tableviewPraise.rowHeight = 40.0;
    //    [tableviewBottom setSeparatorInset:UIEdgeInsetsZero];
    self.tableviewPraise.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    self.tableviewPraise.delegate = self;
    self.tableviewPraise.dataSource = self;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.arrayPraise) {
        return [self.arrayPraise count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath WrokGroupPraiseCell");
    WrokGroupPraiseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WrokGroupPraiseCellIdentify"];
    if (cell == nil)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WrokGroupPraiseCell" owner:self options:nil];
        cell = (WrokGroupPraiseCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setCellDetails:[self.arrayPraise objectAtIndex:indexPath.row] indexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 40.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath row:%li",indexPath.row);

    if (indexPath.row == 0) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPraiseUserIconEvent:)]) {
        [self.delegate clickPraiseUserIconEvent:indexPath.row];
    }
}


-(void)btnIconClickEvent:(NSInteger)index{
    
}

@end
