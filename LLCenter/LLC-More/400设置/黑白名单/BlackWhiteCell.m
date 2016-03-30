//
//  BlackWhiteCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "BlackWhiteCell.h"
#import "LLCenterUtility.h"

@implementation BlackWhiteCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(NSDictionary *)item{
    
    /*
     {
     "ADD_DATE" = 1442388563000;
     "ADD_USER" = 4008016161;
     DISTRICT = "\U4e91\U5357\U7701\U7ea2\U6cb3";
     REMARK = "\U6d4b\U8bd52";
     "SYS_FLAG" = 0;
     "USER_ID" = 4008016161;
     "USER_NO" = 13529843957;
     XH = 1116864204;
     }
     */
    
    self.labelRemark.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-135-15, 20, 135, 20);
    
    NSString *USER_NO = @"";
    if ([item safeObjectForKey:@"USER_NO"]) {
        USER_NO = [item safeObjectForKey:@"USER_NO"];
    }
    
    NSString *DISTRICT = @"";
    if ([item safeObjectForKey:@"DISTRICT"]) {
        DISTRICT = [item safeObjectForKey:@"DISTRICT"];
    }
    
    NSString *REMARK = @"";
    if ([item safeObjectForKey:@"REMARK"]) {
        REMARK = [item safeObjectForKey:@"REMARK"];
    }
    
    self.labelPhone.text = USER_NO;
    self.labelBelongAddress.text = DISTRICT;
    self.labelRemark.text = REMARK;
}

///设置左滑按钮
-(void)setLeftAndRightBtn{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    /*
    ///删除
    NSString *icon = @"entity_operation_follow_cancel.png";
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:COLOR_CELL_RIGHT_BTN_BG icon:[UIImage imageNamed:icon]];
    */
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"删除"];
    
    self.leftUtilityButtons = nil;
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:70.0];
}

@end
