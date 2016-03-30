//
//  MoreCustomerCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-7-6.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//
#define ICON_COLOR0 [UIColor colorWithRed:239.0f/255 green:239.0f/255 blue:244.0f/255 alpha:1.0f]
#import "MoreCustomerCell.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "MoreCustomerItemCell.h"

@interface MoreCustomerCell ()<UITableViewDelegate,UITableViewDataSource,BtnNameClickDelegate> {
    
}
@end

@implementation MoreCustomerCell

- (void)awakeFromNib {
    
    self.imgLine.image = [CommonFunc createImageWithColor:ICON_COLOR0];
    
    self.tableview.frame = CGRectMake(0, 111, 60, DEVICE_BOUNDS_WIDTH-111);
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.backgroundView = nil;
    
    [self.tableview.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    self.tableview.transform = CGAffineTransformMakeRotation(M_PI/-2);
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.frame = CGRectMake(111, 60, DEVICE_BOUNDS_WIDTH-111, 60);
    self.tableview.rowHeight = 60.0;
    //    [tableviewBottom setSeparatorInset:UIEdgeInsetsZero];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(NSArray *)array indexPath:(NSIndexPath *)indexPath{
    
    self.arrayCustomers = array;
    [self.tableview reloadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.arrayCustomers) {
        return [self.arrayCustomers count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MoreCustomerItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCustomerItemCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MoreCustomerItemCell" owner:self options:nil];
        cell = (MoreCustomerItemCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.delegate = self;
    [cell setCellDetails:[[self.arrayCustomers objectAtIndex:indexPath.row] safeObjectForKey:@"NAME"] indexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *name = [[self.arrayCustomers objectAtIndex:indexPath.row] safeObjectForKey:@"NAME"];
    CGSize sizeCustomerName = [CommonFunc getSizeOfContents:name Font:[UIFont systemFontOfSize:17.0] withWidth:180 withHeight:20];
    NSLog(@"sizeCustomerName:%f",sizeCustomerName.width);
    return sizeCustomerName.width+20;
//    return 100.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath row:%li",indexPath.row);
}


-(void)btnNameClickEvent:(NSInteger)index{
    if (self.delegate && [self.delegate respondsToSelector:@selector(gotoCustomerDetails:)]) {
        [self.delegate gotoCustomerDetails:[self.arrayCustomers objectAtIndex:index]];
    }
}

@end
