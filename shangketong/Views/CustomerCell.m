//
//  CustomerCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//


#import "CustomerCell.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"

@implementation CustomerCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(NSDictionary *)item{
    self.imgSelectIcon.hidden = YES;
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    self.labelName.text = name;
    
    long long createdAt = 0;
    if ([item objectForKey:@"createdAt"]) {
        createdAt = [[item safeObjectForKey:@"createdAt"] longLongValue];
    }
    
    NSDate *date = [CommonFuntion stringToDate:[CommonFuntion transDateWithTimeInterval:createdAt withFormat:DATE_FORMAT_yyyyMMddHHmm] Format:DATE_FORMAT_yyyyMMddHHmm];
    NSLog(@"createdAt date:%@",date);
    self.labelDate.text = [CommonFuntion transDateWithFormatDate:date];


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
    self.labelDate.frame = CGRectMake(15, 35, sizeDate.width, 20);
    self.viewSplit.frame = CGRectMake(self.labelDate.frame.origin.x+sizeDate.width+5, 40, 1, 10);
    self.labelMarkInfo.frame = CGRectMake(self.viewSplit.frame.origin.x+6, 35, 150, 20);
}




///设置左滑按钮
-(void)setLeftAndRightBtn:(NSDictionary *)item{
    self.imgSelectIcon.hidden = YES;
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    ///是否可关注
    BOOL canFollow = FALSE;
    if ([item objectForKey:@"canFollow"]) {
        canFollow = [[item objectForKey:@"canFollow"] boolValue];
    }
    
    ///是否被关注
    BOOL isFollow = FALSE;
    if ([item objectForKey:@"isFollow"]) {
        isFollow = [[item objectForKey:@"isFollow"] boolValue];
    }
    
    if (canFollow) {
        NSString *iconFollowName = @"entity_operation_follow.png";
        if (isFollow) {
            iconFollowName = @"entity_operation_follow_cancel.png";
        }else{
            iconFollowName = @"entity_operation_follow.png";
        }
        [rightUtilityButtons sw_addUtilityButtonWithColor:COLOR_CELL_RIGHT_BTN_BG icon:[UIImage imageNamed:iconFollowName]];
    }
    
    
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
    NSString *phone = @"";
    if ([item objectForKey:@"phone"]) {
        phone = [item objectForKey:@"phone"];
    }
    
    NSString *iconPhoneName = @"entity_operation_contact_disable.png";
    if ([phone isEqualToString:@""]) {
        iconPhoneName = @"entity_operation_contact_disable.png";
    }else{
        iconPhoneName = @"entity_operation_contact.png";
    }
    [rightUtilityButtons sw_addUtilityButtonWithColor:COLOR_CELL_RIGHT_BTN_BG icon:[UIImage imageNamed:iconPhoneName]];
    
    self.leftUtilityButtons = nil;
    //    self.rightUtilityButtons = rightUtilityButtons;
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:50.0];
}


///设置选中图标
-(void)setSelectedIconShow:(NSString *)select{
    self.imgSelectIcon.hidden = NO;
    self.imgSelectIcon.frame = CGRectMake(kScreen_Width-31, 22, 16, 16);
    
    if ([select isEqualToString:@"yes"]) {
        [self.imgSelectIcon setImage:[UIImage imageNamed:@"tenant_agree_selected.png"]];
    }else{
        [self.imgSelectIcon setImage:[UIImage imageNamed:@"tenant_agree.png"]];
    }
    
}


-(void)setCellFrame{
    self.labelName.frame = CGRectMake(15,8 , kScreen_Width-50, 20);
}




@end
