//
//  OrderCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "OrderCell.h"
#import "LLCenterUtility.h"

@implementation OrderCell

- (void)awakeFromNib {
    // Initialization code  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(NSDictionary *)item anIndexPath:(NSIndexPath *)indexPath{
    /*
     orderId(订单ID)
     orderName(订单名称)
     orderAmount(订单总金额)
     paymentMethodId(付款方式Id)
     paymentMethodName(付款方式name)
     orderStatusId(状态Id)
     orderStatusName(状态name)
     deliveryDate(发货时间)
     orderRemark(备注)
     */
    
    NSString *orderName = @"";
    if ([item objectForKey:@"orderName"]) {
        orderName = [item safeObjectForKey:@"orderName"];
    }
    ///最多显示6个，多出部门用...表示
    if (orderName.length>6) {
        orderName = [NSString stringWithFormat:@"%@...",[orderName substringToIndex:6]];
    }
    self.labelTitle.text = [NSString stringWithFormat:@"订单名称: %@",orderName];
    
    
    NSString *orderStatusName = @"";
    if ([item objectForKey:@"orderStatusName"]) {
        orderStatusName = [item safeObjectForKey:@"orderStatusName"];
    }
    
    NSString *orderAmount = @"";
    if ([item objectForKey:@"orderAmount"]) {
        orderAmount = [item safeObjectForKey:@"orderAmount"];
    }
    
    
    NSString *paymentMethodName = @"";
    if ([item objectForKey:@"paymentMethodName"]) {
        paymentMethodName = [item safeObjectForKey:@"paymentMethodName"];
    }
    
    NSString *deliveryDate = @"";
    if ([item objectForKey:@"deliveryDate"]) {
        deliveryDate = [item safeObjectForKey:@"deliveryDate"];
    }
    
    
    self.labelStatus.text = [NSString stringWithFormat:@"状态: %@",orderStatusName];
    self.labelAmt.text = [NSString stringWithFormat:@"金额: %@",orderAmount];
    self.labelType.text = [NSString stringWithFormat:@"付款方式: %@",paymentMethodName];
    self.labelCreateDate.text = [NSString stringWithFormat:@"发货日期: %@",deliveryDate];
    
    
    
    BOOL isChecked = FALSE;
    if ([item objectForKey:@"checked"]) {
        isChecked = [[item objectForKey:@"checked"] boolValue];
    }
    
    if (isChecked) {
        [self.btnCheckbox setBackgroundImage:[UIImage imageNamed:@"login_checkbox_filled.png"] forState:UIControlStateNormal];
    }else{
        [self.btnCheckbox setBackgroundImage:[UIImage imageNamed:@"login_checkbox_empty.png"] forState:UIControlStateNormal];
    }
    
    self.btnDetail.tag = indexPath.section;
    [self.btnDetail addTarget:self action:@selector(goEditDetailsView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.btnCheckbox.tag = indexPath.section;
    [self.btnCheckbox addTarget:self action:@selector(selectCheckbox:) forControlEvents:UIControlEventTouchUpInside];
}


///详情页面
- (void)goEditDetailsView:(id)sender {
    NSLog(@"goDetailsView--->");
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    if (self.GotoEditDetailsViewBlock) {
        self.GotoEditDetailsViewBlock(tag);
    }
}


///选择框
- (void)selectCheckbox:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    if (self.NotifyCheckBoxBlock) {
        self.NotifyCheckBoxBlock(tag);
    }
}

///type 1 正常页面  2删除页面
-(void)setCellFrameWithType:(NSInteger)type{
//    self.labelTitle.frame = CGRectMake(15, 10, DEVICE_BOUNDS_WIDTH-30, 20);
//    self.btnDetail.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-40, 5, 25, 25);
    
    if (type ==1) {
        self.btnCheckbox.hidden = YES;
        self.btnDetail.hidden = NO;
        self.labelTitle.frame = CGRectMake(15, 10, DEVICE_BOUNDS_WIDTH-50, 20);
        self.btnDetail.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-40, 5, 21, 25.5);
    }else{
        self.btnCheckbox.hidden = NO;
        self.btnDetail.hidden = YES;
        self.btnCheckbox.frame = CGRectMake(15, 10, 20, 20);
        self.labelTitle.frame = CGRectMake(40, 10, DEVICE_BOUNDS_WIDTH-30, 20);
    }
    
    self.labelStatus.frame = CGRectMake(15, 40, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
    self.labelAmt.frame = CGRectMake(self.labelStatus.frame.origin.x+self.labelStatus.frame.size.width+20, 40, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
    
    self.labelType.frame = CGRectMake(15, 60, (DEVICE_BOUNDS_WIDTH-30-20)/2+10, 20);
    self.labelCreateDate.frame = CGRectMake(self.labelType.frame.origin.x+self.labelType.frame.size.width+10, 60, (DEVICE_BOUNDS_WIDTH-30-20)/2+10, 20);
    
    
    
    
}

@end
