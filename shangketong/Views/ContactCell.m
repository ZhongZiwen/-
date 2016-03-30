//
//  ContactCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ContactCell.h"
#import "CommonConstant.h"

@implementation ContactCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(NSDictionary *)item{
    self.btnSelected.hidden = YES;
    
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item objectForKey:@"name"];
    }
    self.labelName.text = name;
    
    NSString *accountName = @"";
    if ([item objectForKey:@"accountName"]) {
        accountName = [item safeObjectForKey:@"accountName"];
    }
    self.labelAccountName.text = accountName;
}


///设置左滑按钮
-(void)setLeftAndRightBtn:(NSDictionary *)item{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    ///地址
    NSString *address = @"";
    if ([item objectForKey:@"address"]) {
        address = [item safeObjectForKey:@"address"];
    }
    
    NSString *iconAddressName = @"entity_operation_lbs_disable.png";
    if ([address isEqualToString:@""]) {
        iconAddressName = @"entity_operation_lbs_disable.png";
    }else{
        iconAddressName = @"entity_operation_lbs.png";
    }
    [rightUtilityButtons sw_addUtilityButtonWithColor:COLOR_CELL_RIGHT_BTN_BG icon:[UIImage imageNamed:iconAddressName]];
    
    ///手机号
    NSString *mobile = @"";
    if ([item objectForKey:@"mobile"]) {
        mobile = [item safeObjectForKey:@"mobile"];
    }
    
    NSString *iconPhoneName = @"entity_operation_contact_disable.png";
    if ([mobile isEqualToString:@""]) {
        iconPhoneName = @"entity_operation_contact_disable.png";
    }else{
        iconPhoneName = @"entity_operation_contact.png";
    }
    [rightUtilityButtons sw_addUtilityButtonWithColor:COLOR_CELL_RIGHT_BTN_BG icon:[UIImage imageNamed:iconPhoneName]];
    
    self.leftUtilityButtons = nil;
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:50.0];
}

///设置选中与未选中图标
-(void)setSelectedBtnShow:(NSString *)select{
    self.btnSelected.hidden = NO;
    self.btnSelected.frame = CGRectMake(kScreen_Width-31, 17, 16, 16);

    if ([select isEqualToString:@"yes"]) {
        [self.btnSelected setImage:[UIImage imageNamed:@"tenant_agree_selected.png"] forState:UIControlStateNormal];
    }else{
        [self.btnSelected setImage:[UIImage imageNamed:@"tenant_agree.png"] forState:UIControlStateNormal];
    }
}

///设置拨打电话图标
-(void)setCallBtnShow:(NSDictionary *)item index:(NSIndexPath *)indexPath{
    ///手机号
    NSString *mobile = @"";
    if ([item objectForKey:@"mobile"]) {
        mobile = [item safeObjectForKey:@"mobile"];
    }
    
    if ([mobile isEqualToString:@""]) {
        self.btnSelected.hidden = YES;
    }else{
        self.btnSelected.hidden = NO;
    }
    
    self.btnSelected.frame = CGRectMake(kScreen_Width-40, 10, 30, 30);
    [self.btnSelected setImage:[UIImage imageNamed:@"activity_header_call_green.png"] forState:UIControlStateNormal];
    [self.btnSelected setImage:[UIImage imageNamed:@"activity_header_call_gray.png"] forState:UIControlStateHighlighted];
    
    ///添加点击事件
    self.btnSelected.tag = indexPath.row;
    [self.btnSelected addTarget:self action:@selector(callEvent:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)setCellFrame{
    self.labelName.frame = CGRectMake(15, 7, kScreen_Width-50, 20);
    self.labelAccountName.frame = CGRectMake(15, 28, kScreen_Width-50, 20);
}


///拨打电话事件
-(void)callEvent:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    if (self.ccdelegate && [self.ccdelegate respondsToSelector:@selector(callCantact:)]) {
        [self.ccdelegate callCantact:tag];
    }
}

@end
