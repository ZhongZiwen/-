//
//  RingCellB.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "RingCellB.h"
#import "LLCenterUtility.h"


@implementation RingCellB

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(NSDictionary *)item anIndexPath:(NSIndexPath *)indexPath andType:(NSInteger)type{
    /*
     ringId(炫铃ID)
     ringtoneId(铃声ID)
     ringtoneName(铃声名称)
     timeType(时间类型) 0-节假日，1-星期时间
     timeRange(时间范围)
     startTime(开始时间)
     endTime(结束时间)
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
    self.labelDateType.text = [NSString stringWithFormat:@"时间类型: %@",@"星期时间"];
    
    
    self.labelDateRange.text = @"时间范围:";
    
    
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
    
    [self setCellFrameWithType:type andItem:item];
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
-(void)setCellFrameWithType:(NSInteger)type andItem:(NSDictionary *)item {
    
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
    
    NSString *timeRange = @"";
    if ([item objectForKey:@"timeRange"]) {
        timeRange = [item safeObjectForKey:@"timeRange"];
    }
    NSArray *week =  [self getWeekDayByFlag:timeRange];
    
     NSInteger count = 0;
    if (week) {
        count = [week count];
    }
   
    for(UIView *item in self.contentView.subviews){
        if([item isKindOfClass:[UIButton class]]){
            NSInteger tag = [item tag];
            if(tag>=1000){
                [item removeFromSuperview];
            }
        }
    }
    
    CGFloat xPoint = 90.0;
    CGFloat yPoint = 70.0;
    CGFloat width = (DEVICE_BOUNDS_WIDTH-110)/4;
    CGFloat height = 30.0;
    for (int i=0; i<count; i++) {
        
        if (i==4) {
            yPoint += 30.0;
            xPoint = 90.0;
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(xPoint, yPoint, width, height);
        xPoint += width;
        [btn setImage:[UIImage imageNamed:@"img_select_selected.png"] forState:UIControlStateNormal];
        [btn setTitle:[week objectAtIndex:i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        btn.tag = i+1000;
        btn.enabled = NO;
        [self.contentView addSubview:btn];
    }
    
    
    self.labelDateRange.frame = CGRectMake(15, 73, DEVICE_BOUNDS_WIDTH-30-20, 20);
    
    ///开始时间-结束时间
    self.labelStartTime.frame = CGRectMake(15, yPoint+35, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
    self.labelEndTime.frame = CGRectMake(self.labelStartTime.frame.origin.x+self.labelStartTime.frame.size.width+20, yPoint+35, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
    
}



+(CGFloat)getCellHeight:(NSDictionary *)item{
    NSString *timeRange = @"";
    if ([item objectForKey:@"timeRange"]) {
        timeRange = [item safeObjectForKey:@"timeRange"];
    }
    NSArray *week = [timeRange componentsSeparatedByString:@","];
    NSInteger count = 0;
    if (week) {
        count = [week count];
    }
    NSInteger rangeHeight = 30;
    if (count > 4) {
        rangeHeight = 60;
    }
    
    return 105.0+rangeHeight;
}


-(NSArray *)getWeekDayByFlag:(NSString *)strFlags{
    NSArray *arrWeek = [strFlags componentsSeparatedByString:@","];
    NSInteger count = 0;
    if (arrWeek) {
        count = [arrWeek count];
    }
    
    ///对星期做排序
    NSArray *resultkArrSortWeek = [arrWeek sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *arrMutableWeek = [[NSMutableArray alloc] init];
    for (int i=0; i<count; i++) {
        NSInteger weekFlag = [[resultkArrSortWeek objectAtIndex:i] integerValue];
        switch (weekFlag) {
            case 1:
                [arrMutableWeek addObject:@"周一"];
                break;
            case 2:
                [arrMutableWeek addObject:@"周二"];
                break;
            case 3:
                [arrMutableWeek addObject:@"周三"];
                break;
            case 4:
                [arrMutableWeek addObject:@"周四"];
                break;
            case 5:
                [arrMutableWeek addObject:@"周五"];
                break;
            case 6:
                [arrMutableWeek addObject:@"周六"];
                break;
            case 7:
                [arrMutableWeek addObject:@"周日"];
                break;
                
            default:
                break;
        }
    }
    return arrMutableWeek;
}



@end
