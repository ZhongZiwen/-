//
//  SaleLeadSearchResultCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SaleLeadSearchResultCell.h"

@implementation SaleLeadSearchResultCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


///设置cell详情
-(void)setCellDetails:(NSDictionary *)item{
    
    ///name
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    self.labelName.frame = CGRectMake(15, 5, kScreen_Width-40, 20);
    self.labelName.text = name;
    
    ///companyname
    NSString *companyName = @"";
    if ([item objectForKey:@"companyName"]) {
        companyName = [item safeObjectForKey:@"companyName"];
    }
    self.labelCompanyName.frame = CGRectMake(15, 25, kScreen_Width-40, 20);
    self.labelCompanyName.text = companyName;
}

@end
