//
//  PlanCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-5-30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PlanCell.h"
#import "CommonConstant.h"
@interface PlanCell ()

@property (nonatomic, assign) long long planID;
@end
@implementation PlanCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


///设置当前item的详情
-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)index{
    NSInteger flagType = 0;
    if ([[item objectForKey:@"flag"] isEqualToString:@"tasks"]) {
        flagType = 1;
    } else if ([[item objectForKey:@"flag"] isEqualToString:@"schedules"] && [[item safeObjectForKey:@"isAllDay"] integerValue] == 0) {
        flagType = 1;
    } else if ([[item objectForKey:@"flag"] isEqualToString:@"victor"]) {
        flagType = 2;
    } else {
        flagType = 3;
    }
    if ([[item objectForKey:@"flag"] isEqualToString:@"tasks"] && [[item objectForKey:@"status"] integerValue] == 3) {
        [self.btnSelect addTarget:self action:@selector(clickSelectBtn) forControlEvents:UIControlEventTouchUpInside];
        _planID = [[item safeObjectForKey:@"id"] longLongValue];
    }
    
    [self setCellFrameByType:flagType];
}
///设置左滑按钮
-(void)setLeftAndRightBtn:(NSInteger )typeCell withItemDetail:(NSDictionary *)item{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    ///任务
    if ([[item objectForKey:@"flag"] isEqualToString:@"tasks"]) {
        long long createID; //创建人id
        long long ownerID = 0; //责任人id
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"createdBy"]]) {
            createID = [[[item objectForKey:@"createdBy"] safeObjectForKey:@"id"] longLongValue];
        }
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"owner"]]) {
            ownerID = [[[item objectForKey:@"owner"] safeObjectForKey:@"id"] longLongValue];
        }
        
        //1待接收,2未完成,3已完成,4被拒绝,5已过期
        NSInteger statusValue = 0;
        if ([item objectForKey:@"taskStatus"]) {
            statusValue = [[item objectForKey:@"taskStatus"] integerValue];
        }
        
        ///创建人
        BOOL isMe = FALSE;
        if (createID == [appDelegateAccessor.moudle.userId longLongValue]) {
            isMe = TRUE;
        }
        
        ///负责
        BOOL isResponsible = FALSE;
        if (!isMe && ownerID == [appDelegateAccessor.moudle.userId longLongValue] ) {
            isResponsible = TRUE;
        }
        
        
        
        ///创建人
        if (isMe) {
            ///已完成
            if (statusValue == 3) {
                [rightUtilityButtons sw_addUtilityButtonWithColor:SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_RESET title:@"重启"];
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"删除"];
                
            }else if (statusValue == 1 || statusValue == 4) {
                ///被拒绝 待接收
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"删除"];
            }else {
                [rightUtilityButtons sw_addUtilityButtonWithColor:SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_OVER title:@"完成"];
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"删除"];
            }
            
        }else if(isResponsible){
            
            //1待接收,2未完成,3已完成,4被拒绝,5已过期
            ///责任
            ///已完成
            if (statusValue == 3) {
                [rightUtilityButtons sw_addUtilityButtonWithColor:SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_RESET title:@"重启"];
            }else if (statusValue == 1){
                NSString *iconAcceptName = @"接受";
                [rightUtilityButtons sw_addUtilityButtonWithColor:SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_ACCEPT title:iconAcceptName];
                NSString *iconRefuseName = @"拒绝";
                [rightUtilityButtons sw_addUtilityButtonWithColor:SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_REFUSE title:iconRefuseName];
            }else{
                [rightUtilityButtons sw_addUtilityButtonWithColor:SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_OVER title:@"完成"];
            }
            
        }else{
            ///参与人
            NSString *iconDeleteName = @"退出";
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:iconDeleteName];
        }
        
    }else{
        
        if (typeCell == 1) {
            NSString *iconDeleteName = @"删除";
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:iconDeleteName];
        } else if (typeCell == 0) {
            NSString *iconAcceptName = @"接受";
            [rightUtilityButtons sw_addUtilityButtonWithColor:SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_ACCEPT title:iconAcceptName];
            NSString *iconRefuseName = @"拒绝";
            [rightUtilityButtons sw_addUtilityButtonWithColor:SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_REFUSE title:iconRefuseName];
        } else if (typeCell == 2) {
            NSString *iconDeleteName = @"退出";
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:iconDeleteName];
        } else {
            
        }
    }
    
    self.leftUtilityButtons = nil;
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:65.0];
}
///添加添加事件 --  暂时没有用到
-(void)addClickEventForBtnSelect:(NSInteger)index{
    [self.btnSelect addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.btnSelect.tag = index;
}

///点击编辑框事件
-(void)clickSelectBtn{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(clickSelectBtnEvent:)]) {
//        [self.delegate clickSelectBtnEvent:_planID];
//    }
}

///根据当前cell的类型 设置frame
/// type 1  11：00  框  名称
/// type 2  喜报
/// type 3 上下两行
-(void)setCellFrameByType:(NSInteger)type{
    self.imgIcon.hidden = YES;
    self.labelTitleB.hidden = YES;
    
    self.btnSelect.layer.cornerRadius = 0;
    self.btnSelect.layer.masksToBounds = YES;
    
    if (type == 1) {
        self.labelTime.frame = CGRectMake(15, 17, 60, 20);
        self.btnSelect.frame = CGRectMake(self.labelTime.frame.origin.x+60+15, 15,20 , 20);
        self.labelTitleA.frame = CGRectMake(self.btnSelect.frame.origin.x+25+15, 15,kScreen_Width-(self.btnSelect.frame.origin.x+25+15)-30 , 20);
    }else if (type == 2){
        ///喜报
        self.labelTitleB.hidden = NO;
        self.imgIcon.hidden = YES;
        self.labelTime.frame = CGRectMake(15, 17, 60, 20);
        self.btnSelect.frame = CGRectMake(self.labelTime.frame.origin.x+60+15, 20,15 , 15);
        self.btnSelect.layer.cornerRadius = self.btnSelect.frame.size.width/2;
        self.labelTitleA.frame = CGRectMake(self.btnSelect.frame.origin.x+25+15, 5,kScreen_Width-(self.btnSelect.frame.origin.x+25+15)-30 , 20);
        self.labelTitleB.frame = CGRectMake(self.btnSelect.frame.origin.x+25+15, 25,kScreen_Width-(self.btnSelect.frame.origin.x+25+15)-30 , 20);
    }else if (type == 3){
        ///上下两行
        self.imgIcon.hidden = NO;
        self.labelTitleB.hidden = NO;
        
        self.labelTime.frame = CGRectMake(15, 17, 60, 20);
        self.btnSelect.frame = CGRectMake(self.labelTime.frame.origin.x+60+23, 22,10 , 10);
        self.btnSelect.layer.cornerRadius = self.btnSelect.frame.size.width/2;
        
        self.labelTitleA.frame = CGRectMake(self.btnSelect.frame.origin.x+25+15, 7,kScreen_Width-(self.btnSelect.frame.origin.x+25+15)-30 , 20);
        
        self.imgIcon.frame = CGRectMake(self.btnSelect.frame.origin.x+25+15, 32,11 , 11);
        self.labelTitleB.frame = CGRectMake(self.btnSelect.frame.origin.x+25+15+11+5, 27,kScreen_Width-(self.btnSelect.frame.origin.x+25+15)-30 , 20);
    }
}

@end
