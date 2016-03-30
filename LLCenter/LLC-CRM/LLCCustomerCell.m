//
//  LLCCustomerCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-7-2.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "LLCCustomerCell.h"
#import "LLCenterUtility.h"

@implementation LLCCustomerCell

- (void)awakeFromNib {
    // Initialization code
    self.imgIcon.hidden = YES;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(NSDictionary *)item{
    
    NSString *name = @"";
    NSString *companyName = @"";
    
    if ([item objectForKey:@"LINKMAN_NAME"]) {
        name = [item safeObjectForKey:@"LINKMAN_NAME"];
    }
    
    if ([item objectForKey:@"CUSTOMER_NAME"]) {
        companyName = [item safeObjectForKey:@"CUSTOMER_NAME"];
    }
    
    self.labelName.text = name;
    self.labelCompany.text = companyName;
}

-(void)setCellFrame{
    NSInteger vX = DEVICE_BOUNDS_WIDTH-320;
    
    self.labelName.frame = CGRectMake(15, 10, 245+vX, 20);
    self.labelCompany.frame = CGRectMake(15, 30, 245+vX, 20);
    self.imgIcon.frame = CGRectMake(280+vX, 21, 18, 18);
}


@end
