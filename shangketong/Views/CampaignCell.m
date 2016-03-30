//
//  CampaignCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CampaignCell.h"
#import "CommonConstant.h"
#import "CommonModuleFuntion.h"
#import "Campaign.h"
@implementation CampaignCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(Campaign *)item {
    self.labelStatus.hidden = YES;
    self.labelName.text = item.m_name;
    
//    NSString *status = [CommonModuleFuntion getCampaignStatusName:item.m_status];
//    self.labelStatus.text = status;
}

///设置左滑按钮
-(void)setLeftAndRightBtn:(Campaign *)item{
    
    NSString *iconFollowName = @"entity_operation_follow.png";
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    if (item.m_focus == 0) {
        iconFollowName = @"entity_operation_follow_cancel.png";
    }else{
        iconFollowName = @"entity_operation_follow.png";
    }
    [rightUtilityButtons sw_addUtilityButtonWithColor:COLOR_CELL_RIGHT_BTN_BG icon:[UIImage imageNamed:iconFollowName]];
    
    self.leftUtilityButtons = nil;
//    self.rightUtilityButtons = rightUtilityButtons;
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:60.0];
}


-(void)setCellFrame{
    self.labelName.frame = CGRectMake(15, 15, kScreen_Width-30, 20);
    self.labelStatus.frame = CGRectMake(15, 26, kScreen_Width-30, 20);
}

@end
