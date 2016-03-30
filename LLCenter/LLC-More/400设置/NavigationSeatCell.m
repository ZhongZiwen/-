//
//  NavigationSeatCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-26.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "NavigationSeatCell.h"
#import "LLCenterUtility.h"

@implementation NavigationSeatCell

- (void)awakeFromNib {
    
    self.labelPhone.frame = CGRectMake(210, 15, DEVICE_BOUNDS_WIDTH-210, 20);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(NSDictionary *)item{
    /*
     sitName 座席名称;
     sitNo 工号;
     sitPhone 绑定号码;
     waitDuration等待时长
     strategy 策略
     
     
     CALLORDER = 232537600;
     COMPANYID = "5a198602-a925-4a2c-a4fa-cd2aa4b63a20";
     LSH = 232537500;
     NUM = 1;
     SITID = "896a2b42-a9a7-49b5-8837-84a0b498cd1f";
     SITNAME = "\U9093\U7ea2\U65d7";
     SITNO = 2001;
     SITPHONE = 13918745346;
     USERID = "23505287-1c30-43fd-b1a3-2ee8fe0e92a5";
     WAITDURATION = 25;
     
     
     */
    NSString *sitName = @"";
    NSString *sitNo = @"";
    NSString *sitPhone = @"";
    
    if ([item objectForKey:@"SITNAME"]) {
        sitName = [item safeObjectForKey:@"SITNAME"];
    }
    
    if ([item objectForKey:@"SITNO"]) {
        sitNo = [item safeObjectForKey:@"SITNO"];
    }
    
    if ([item objectForKey:@"SITPHONE"]) {
        sitPhone = [item safeObjectForKey:@"SITPHONE"];
    }
    
    self.labelName.text = sitName;
    self.labelNo.text = sitNo;
    self.labelPhone.text = sitPhone;
}

@end
