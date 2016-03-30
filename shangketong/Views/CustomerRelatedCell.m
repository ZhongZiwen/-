//
//  CustomerRelatedCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomerRelatedCell.h"

@implementation CustomerRelatedCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///设置详情
-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    ///姓名
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    self.labelName.text = name;
    self.labelName.frame = CGRectMake(15, 11, kScreen_Width-60, 20);
    
    ///状态
    NSString *partakeStatus = @"";
    if ([item objectForKey:@"participateState"]) {
        partakeStatus = [item safeObjectForKey:@"participateState"];
    }
    self.labelStatus.text = partakeStatus;
    self.labelStatus.frame = CGRectMake(15, 34, kScreen_Width-60, 20);
    
    ///phone
    NSString *phone = @"";
    if ([item objectForKey:@"phone"]) {
        phone = [item safeObjectForKey:@"phone"];
    }
    self.btnCall.frame = CGRectMake(kScreen_Width-40, 20, 20, 20);
    self.btnCall.hidden = YES;
    
    if (![phone isEqualToString:@""]) {
        self.btnCall.hidden = NO;
        self.btnCall.userInteractionEnabled = YES;
        self.btnCall.tag = indexPath.row;
        [self.btnCall addTarget:self action:@selector(callCustomer:) forControlEvents:UIControlEventTouchUpInside];
    }
}

///拨打电话事件
-(void)callCustomer:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    NSLog(@"callCustomer tag:%ti",tag);
    if (self.CallCusotmerBlock != nil) {
        self.CallCusotmerBlock(tag);
    }
}

///设置左滑按钮
-(void)setLeftAndRightBtn{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"删除"];
    self.leftUtilityButtons = nil;
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:50.0];
}

@end
