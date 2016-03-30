//
//  SaleLeadCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SaleLeadCell.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"

@implementation SaleLeadCell

- (void)awakeFromNib {
    // Initialization code
    self.labelName.font = [UIFont systemFontOfSize:14.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(NSDictionary *)item{
    
    ///name
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    CGSize sizeName = [CommonFuntion getSizeOfContents:name Font:[UIFont systemFontOfSize:14.0] withWidth:kScreen_Width-80 withHeight:20];
    self.labelName.frame = CGRectMake(20, 3, sizeName.width, 20);
    self.labelName.text = name;
    
    ///new
    self.imgNew.hidden = NO;
    self.imgNew.frame = CGRectMake(self.labelName.frame.origin.x+sizeName.width+10, 5, 30, 15);
    
    ///companyname
    NSString *companyName = @"";
    if ([item objectForKey:@"companyName"]) {
        companyName = [item safeObjectForKey:@"companyName"];
    }
    self.labelCompanyName.frame = CGRectMake(20, 23, kScreen_Width-40, 20);
    self.labelCompanyName.text = companyName;
    
        ///日期
    long long createdAt = 0;
    if ([item objectForKey:@"createdAt"]) {
        createdAt = [[item safeObjectForKey:@"createdAt"] longLongValue];
    }

    NSDate *date = [CommonFuntion stringToDate:[CommonFuntion transDateWithTimeInterval:createdAt withFormat:DATE_FORMAT_yyyyMMddHHmm] Format:DATE_FORMAT_yyyyMMddHHmm];
    NSLog(@"createdAt date:%@",date);
    self.labelDate.text = [CommonFuntion transDateWithFormatDate:date];
    
    /// 3天后回收
    if ([item objectForKey:@"expireTime"]) {
        
        if ([[item safeObjectForKey:@"expireTime"] longLongValue] <= 0 ) {
            self.labelMarkInfo.hidden = YES;
            self.viewSplit.hidden = YES;
        }else{
            self.labelMarkInfo.hidden = NO;
            self.viewSplit.hidden = NO;
            /// 转换几天后回收
            long long expireTime = 0;
            if ([item objectForKey:@"expireTime"]) {
                expireTime = [[item safeObjectForKey:@"expireTime"] longLongValue];
            }
            
            NSDate *dateExpireTime = [[NSDate alloc]initWithTimeIntervalSince1970:expireTime/1000.0];
            ///时差
            NSTimeInterval tInterval = [dateExpireTime timeIntervalSinceDate:[NSDate date]];
            
            if (tInterval <= 0) {
                self.labelMarkInfo.hidden = YES;
                self.viewSplit.hidden = YES;
            }else{
                if (tInterval < HOUR_OF_SECONDS) {
                    self.labelMarkInfo.text = [NSString stringWithFormat:@"%i分钟后回收",(int)tInterval/60];
                }else  if (tInterval < DAY_OF_SECONDS) {
                    self.labelMarkInfo.text = [NSString stringWithFormat:@"%i小时后回收",(int)tInterval/HOUR_OF_SECONDS];
                }else {
                    NSInteger count = tInterval/DAY_OF_SECONDS;
                    self.labelMarkInfo.text = [NSString stringWithFormat:@"%li天后回收",count];
                }
            }

        }
    }
    
    CGSize sizeDate = [CommonFuntion getSizeOfContents:self.labelDate.text Font:[UIFont systemFontOfSize:12] withWidth:200 withHeight:20];
    self.labelDate.frame = CGRectMake(20, 40, sizeDate.width, 20);
    self.viewSplit.frame = CGRectMake(self.labelDate.frame.origin.x+sizeDate.width+5, 45, 1, 10);
    self.labelMarkInfo.frame = CGRectMake(self.viewSplit.frame.origin.x+6, 40, 150, 20);
    
}

///设置左滑按钮
-(void)setLeftAndRightBtn:(NSDictionary *)item{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    
    ///地址
    NSString *address = @"";
    if ([item objectForKey:@"address"]) {
        address = [item objectForKey:@"address"];
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
        mobile = [item objectForKey:@"mobile"];
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

@end
