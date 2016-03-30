//
//  RingCellA.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "RingCellA.h"
#import "LLCenterUtility.h"

@implementation RingCellA

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(NSDictionary *)item anIndexPath:(NSIndexPath *)indexPath{
    /*
     ringId(炫铃ID)
     ringtoneId(铃声ID)
     ringtoneName(铃声名称)
     timeType(时间类型)
     timeRange(时间范围)
     startTime(开始时间)
     endTime(结束时间)
     */
    
    
    /*
     {
     endTime = "09:59";
     ringId = "0daf1958-6cb8-4bfe-9318-607940ecfc27";
     ringtoneId = 116869132;
     ringtoneName = "\U7535\U8bdd\U8f6c\U63a5\U4e2d.wav";
     startTime = "09:59";
     timeRange = "2015-10-17-2015-10-26";
     timeType = "\U8282\U5047\U65e5";
     }
     */
    
    NSString *ringName = @"";
    if ([item objectForKey:@"ringtoneName"]) {
        ringName = [item safeObjectForKey:@"ringtoneName"];
    }
    
    ///最多显示8个，多出部门用...表示
    if (ringName.length>8) {
        ringName = [NSString stringWithFormat:@"%@...",[ringName substringToIndex:8]];
    }
    
    self.labelRingName.text = [NSString stringWithFormat:@"炫铃名称: %@",ringName];
    
    
    NSString *timeType = @"";
    if ([item objectForKey:@"timeType"]) {
        timeType = [item safeObjectForKey:@"timeType"];
    }
    NSLog(@"timeType:%@",timeType);
    self.labelDateType.text = [NSString stringWithFormat:@"时间类型: %@",@"节假日"];
    
    
    NSString *timeRange = @"";
    if ([item objectForKey:@"timeRange"]) {
        timeRange = [item safeObjectForKey:@"timeRange"];
    }
    NSLog(@"timeRange:%@",timeRange);
    
    self.labelDateRange.text = [NSString stringWithFormat:@"时间范围: %@",timeRange];
    
    
    NSString *startTime = @"";
    if ([item objectForKey:@"startTime"]) {
        startTime = [item safeObjectForKey:@"startTime"];
    }
    self.labelStartTime.text = [NSString stringWithFormat:@"开始时间: %@",startTime];
    
    NSString *endTime = @"";
    if ([item objectForKey:@"endTime"]) {
        endTime = [item safeObjectForKey:@"endTime"];
    }
    self.labelEndTime.text = [NSString stringWithFormat:@"结束时间: %@",endTime];
    

    BOOL isChecked = FALSE;
    if ([item objectForKey:@"checked"]) {
        isChecked = [[item objectForKey:@"checked"] boolValue];
    }
    
    if (isChecked) {
        [self.btnCheckBox setBackgroundImage:[UIImage imageNamed:@"login_checkbox_filled.png"] forState:UIControlStateNormal];
    }else{
        [self.btnCheckBox setBackgroundImage:[UIImage imageNamed:@"login_checkbox_empty.png"] forState:UIControlStateNormal];
    }
    
    self.btnDetail.tag = indexPath.section;
    [self.btnDetail addTarget:self action:@selector(goEditDetailsView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.btnCheckBox.tag = indexPath.section;
    [self.btnCheckBox addTarget:self action:@selector(selectCheckbox:) forControlEvents:UIControlEventTouchUpInside];
}


///详情页面
- (void)goEditDetailsView:(id)sender {
    NSLog(@"goDetailsView--->");
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    if (self.GotoEditDetailsViewBlock) {
        self.GotoEditDetailsViewBlock(tag);
    }
}


///选择框
- (void)selectCheckbox:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    if (self.NotifyCheckBoxBlock) {
        self.NotifyCheckBoxBlock(tag);
    }
}

///type 1 正常页面  2删除页面
-(void)setCellFrameWithType:(NSInteger)type{
    
    if (type ==1) {
        self.btnCheckBox.hidden = YES;
        self.btnDetail.hidden = NO;
        self.labelRingName.frame = CGRectMake(15, 10, DEVICE_BOUNDS_WIDTH-50, 20);
        self.btnDetail.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-40, 5, 22, 27);
    }else{
        self.btnCheckBox.hidden = NO;
        self.btnDetail.hidden = YES;
        self.btnCheckBox.frame = CGRectMake(15, 10, 20, 20);
        self.labelRingName.frame = CGRectMake(40, 10, DEVICE_BOUNDS_WIDTH-30, 20);
    }
    
    
    self.labelDateType.frame = CGRectMake(15, 40, DEVICE_BOUNDS_WIDTH-30-20, 20);
    self.labelDateRange.frame = CGRectMake(15, 70, DEVICE_BOUNDS_WIDTH-30-20, 20);
    
    ///开始时间-结束时间
    self.labelStartTime.frame = CGRectMake(15, 100, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
    self.labelEndTime.frame = CGRectMake(self.labelStartTime.frame.origin.x+self.labelStartTime.frame.size.width+20, 100, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
    
}

+(CGFloat)getCellHeight{
    return 130.0;
}

@end
