//
//  SaleOpportunityGroupCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SaleOpportunityGroupCell.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"

@implementation SaleOpportunityGroupCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///设置cell详情
-(void)setCellDetails:(NSDictionary *)item currencyUnit:(NSString *)unit {
    
    ///stageName
    NSString *stageName = @"";
    if ([item objectForKey:@"stageName"]) {
        stageName = [item safeObjectForKey:@"stageName"];
    }
#warning percent类型？
    NSInteger percent = 0;
    if ([item objectForKey:@"percent"]) {
        percent = [[item safeObjectForKey:@"percent"] integerValue];
    }

    NSString *name_percent = [NSString stringWithFormat:@"%@(%ti%%)",stageName,percent];
    
    CGSize sizeName = [CommonFuntion getSizeOfContents:name_percent Font:[UIFont systemFontOfSize:15.0] withWidth:kScreen_Width-150 withHeight:20];
    
    
    self.labelName.frame = CGRectMake(15, 20, sizeName.width, 20);
    self.labelName.text = name_percent;
    
    
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
    
    
    self.labelMoney.frame = [CommonFuntion setViewFrameOffset:self.labelMoney.frame byX:kScreen_Width-320 byY:0 ByWidth:0 byHeight:0];
    self.labelMoney.text = stringMoney;
    
    self.imgIcon.frame = [CommonFuntion setViewFrameOffset:self.imgIcon.frame byX:kScreen_Width-320 byY:0 ByWidth:0 byHeight:0];
}


@end
