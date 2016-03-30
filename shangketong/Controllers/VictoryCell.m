//
//  VictoryCell.m
//  shangketong
//
//  Created by zjp on 15/12/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "VictoryCell.h"
#import "CommonFuntion.h"
@implementation VictoryCell

- (void)awakeFromNib {
    
    self.labelTitle.frame = CGRectMake(15, 10, kScreen_Width-80, 20);
    self.labelInfo.frame = CGRectMake(15, 35, kScreen_Width-80, 20);
    self.labelName.frame = CGRectMake(15, 55, kScreen_Width-80, 20);
    self.btnShare.frame = CGRectMake(kScreen_Width-60, 22, 50, 35);
    self.btnShare.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(NSDictionary *)item{
    NSLog(@"item:%@",item);
    /*
     opportunitys
     id	销售机会id
     name	销售机会名字
     customerName	销售机会所属客户名字
     money	销售机会金额
     focus	是否已关注当前销售机会
     ownerName	销售机会所有人名字
     */
    
    
    NSString *name = [item safeObjectForKey:@"name"];
    if ([name isEqualToString:@""]) {
        name = @"";
    }
    
    NSString *money = [item safeObjectForKey:@"money"];
    if (![money isEqualToString:@""]) {
        money = [NSString stringWithFormat:@"%@元",money];
    }
    
    NSString *customerName = [item safeObjectForKey:@"customerName"];
    if ([customerName isEqualToString:@""]) {
        customerName = @"";
    }
    
    NSString *ownerName = [item safeObjectForKey:@"ownerName"];
    if ([ownerName isEqualToString:@""]) {
        ownerName = @"未填写";
    }
    
    
    self.labelTitle.text = name;
    self.labelInfo.text = [NSString stringWithFormat:@"%@ %@",money,customerName];
    self.labelName.text = ownerName;
}


@end
