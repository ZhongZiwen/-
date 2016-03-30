//
//  SaleOpportunityCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SaleOpportunityCell.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"

@implementation SaleOpportunityCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///设置cell详情
-(void)setCellDetails:(NSDictionary *)item currencyUnit:(NSString *)unit index:(NSIndexPath *)indexPath {
    self.btnFollow.hidden = YES;
    
    ///name
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    CGSize sizeName = [CommonFuntion getSizeOfContents:name Font:[UIFont systemFontOfSize:15.0] withWidth:kScreen_Width-70 withHeight:20];
    self.labelName.frame = CGRectMake(15, 10, sizeName.width, 20);
    self.labelName.text = name;
    
    ///price
    long long money = 0;
    if ([item objectForKey:@"money"]) {
        money = [[item safeObjectForKey:@"money"] longLongValue];
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    formatter.numberStyle = kCFNumberFormatterCurrencyStyle;
    [formatter setPositiveFormat:@"###,##0;"];
    NSString *stringMoney = @"0";
    if (money > 0) {
        stringMoney = [NSString stringWithFormat:@"%@%@",[[formatter stringFromNumber:[NSNumber numberWithLongLong:money]] stringByReplacingOccurrencesOfString:@"￥" withString:@""],unit];
    }else{
        stringMoney = [NSString stringWithFormat:@"%@%@",@"0",unit];
    }
    CGSize sizeMoney = [CommonFuntion getSizeOfContents:stringMoney Font:[UIFont systemFontOfSize:12.0] withWidth:kScreen_Width-100 withHeight:20];
    self.labelPrice.frame = CGRectMake(15, 30, sizeMoney.width, 20);
    self.labelPrice.text = stringMoney;
    
    ///split
    self.imgSplit.frame = CGRectMake(self.labelPrice.frame.origin.x+sizeMoney.width+4, 35, 1, 10);
    
    ///accountName
    NSString *accountName = @"";
    if ([item objectForKey:@"accountName"]) {
        accountName = [item safeObjectForKey:@"accountName"];
    }
    CGSize sizeAccountName = [CommonFuntion getSizeOfContents:accountName Font:[UIFont systemFontOfSize:12.0] withWidth:kScreen_Width-sizeMoney.width-60 withHeight:20];
    
    self.labelCompanyName.frame = CGRectMake(self.imgSplit.frame.origin.x+5, 30, sizeAccountName.width, 20);
    self.labelCompanyName.text = accountName;
}

///关注按钮
-(void)setFollowBtnShow:(NSDictionary *)item index:(NSIndexPath *)indexPath{
    ///btn follow
    self.btnFollow.frame = CGRectMake(kScreen_Width-20-20, 20, 20, 20);
    self.btnFollow.hidden = YES;
    ///是否可关注
    BOOL canFollow = FALSE;
    if ([item objectForKey:@"canFollow"]) {
        canFollow = [[item safeObjectForKey:@"canFollow"] boolValue];
    }
    
    ///是否被关注
    BOOL isFollow = FALSE;
    if ([item objectForKey:@"isFollow"]) {
        isFollow = [[item safeObjectForKey:@"isFollow"] boolValue];
    }
    
    if (canFollow) {
        self.btnFollow.hidden = NO;
        NSString *iconFollowName = @"accessory_focus_normal.png";
        if (isFollow) {
            iconFollowName = @"accessory_focus_select.png";
        }else{
            iconFollowName = @"accessory_focus_normal.png";
        }
        [self.btnFollow setBackgroundImage:[UIImage imageNamed:iconFollowName] forState:UIControlStateNormal];
        
        ///添加点击事件
        self.btnFollow.tag = indexPath.row;
        [self.btnFollow addTarget:self action:@selector(followEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
}


///关注事件
-(void)followEvent:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    if (self.sodelegate && [self.sodelegate respondsToSelector:@selector(followCustomer:)]) {
        [self.sodelegate followCustomer:tag];
    }
}


///设置左滑按钮
-(void)setLeftAndRightBtn:(NSDictionary *)item{
    BOOL isFollow = FALSE;
    if ([item objectForKey:@"isFollow"]) {
        isFollow = [[item safeObjectForKey:@"isFollow"] boolValue];
    }
    NSString *iconFollowName = @"entity_operation_follow.png";
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    if (isFollow) {
        iconFollowName = @"entity_operation_follow_cancel.png";
    }else{
        iconFollowName = @"entity_operation_follow.png";
    }
    [rightUtilityButtons sw_addUtilityButtonWithColor:COLOR_CELL_RIGHT_BTN_BG icon:[UIImage imageNamed:iconFollowName]];
    
    self.leftUtilityButtons = nil;
    //    self.rightUtilityButtons = rightUtilityButtons;
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:60.0];
}

@end
