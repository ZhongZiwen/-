//
//  TodayScheduleExpMenuCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TodayScheduleExpMenuCell.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"


#define KBUTTONSIZEWIDTH 80
#define KBUTTONSIZEHIGTH 50
#define KLABELSIZEWIDTH 80
#define KLABELSIZEHIGTH 20
// 日程  1下一步 2延时 3删除 4接受 5拒绝 6退出  地址7 备忘8 联系人9
// 任务  1完成 2延时 3删除 4接受 5拒绝  6退出  地址7 备忘8 联系人9
#define KBUTTONIMAGENAME_7 @"entity_operation_lbs" //地址
#define KBUTTONIMAGENAME_8 @"today_operation_activity_add" //备忘
#define KBUTTONIMAGENAME_1  @"today_operation_follow" //下一步
#define KBUTTONIMAGENAME_1001 @"today_operation_more" //更多
#define KBUTTONIMAGENAME_1002 @"today_operation_back" //返回
#define KBUTTONIMAGENAME_9 @"today_operation_contact" //联系
#define KBUTTONIMAGENAME_2 @"today_operation_delay" //延时
#define KBUTTONIMAGENAME_3 @"today_operation_delete" //删除
#define KBUTTONIMAGENAME_4 @"today_operation_accept" //接受
#define KBUTTONIMAGENAME_5 @"today_operation_refuse" //拒绝
#define KBUTTONIMAGENAME_6 @"today_operation_quit"  //退出
#define KBUTTONIMAGENAME_11 @"today_operation_finish"  //完成

@implementation TodayScheduleExpMenuCell
{
    NSString *flagForShowOrHidden; //标记  按钮的显示与隐藏
    NSInteger dataId; //此数据的id
    NSInteger scheduleType; //区分 日程 1删除 和 0退出
    NSInteger taskType; //区分 任务 1待接收 和 0已接受
    NSInteger hasAddress; //是否有地址 1有 0没有
    NSInteger hasPhoneNumber; //是否有手机号 1有  0没有
    NSInteger hasMark; //是否又备忘 1有  0没有
    NSMutableArray *dataSourceArray;
}

- (void)awakeFromNib {
    // Initialization code
    _label1.textColor = LIGHT_BLUE_COLOR;
    _label2.textColor = LIGHT_BLUE_COLOR;
    _label3.textColor = LIGHT_BLUE_COLOR;
    _label4.textColor = LIGHT_BLUE_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellContentDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath {
    dataSourceArray = [NSMutableArray arrayWithCapacity:0];
    NSInteger count = 0;
     NSString *flagStr = @"";
    _dataId = [[item safeObjectForKey:@"id"] integerValue];
    //判断有没有地址
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"address"]]) {
        hasAddress = 1;
    } else {
        hasAddress = 0;
    }
    //判断有没有备忘
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"from"]] && [[[item objectForKey:@"from"] allKeys] count] > 0) {
        hasMark = 1;
    } else {
        hasMark = 0;
    }
    
    //判断有没有联系方式
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"linkMans"]] && [[item objectForKey:@"linkMans"] count] > 0) {
        hasPhoneNumber = 1;
    } else {
        hasPhoneNumber = 0;
    }
    // 日程  1下一步 2延时 3删除 4接受 5拒绝 6退出  地址7 备忘8 联系人9
    NSInteger creatId , ownerId , taskStatus; //负责人， 参与人
    if ([[item objectForKey:@"flag"] isEqualToString:@"schedules"]) {
        _dataType = DataSourceTypeSchedule;
        creatId = [[item safeObjectForKey:@"createdBy"] integerValue];
        //10 待接受
        if ([[item safeObjectForKey:@"myState"] integerValue] != 10) {
            //该日程非待接受状态。  二级菜单。下一步， 延时， 删除/退出
            [dataSourceArray addObject:@{@"name" : @"下一步", @"tag" : @"1" , @"image" : KBUTTONIMAGENAME_1}];
            [dataSourceArray addObject:@{@"name" : @"延时", @"tag" : @"2", @"image" : KBUTTONIMAGENAME_2}];
            
            if (creatId == [appDelegateAccessor.moudle.userId integerValue]) {
                scheduleType = 1;
                [dataSourceArray addObject:@{@"name" : @"删除", @"tag" : @"3", @"image" : KBUTTONIMAGENAME_3}];
            } else {
                scheduleType = 0;
                [dataSourceArray addObject:@{@"name" : @"退出", @"tag" : @"6", @"image" : KBUTTONIMAGENAME_6}];
            }
            count = 3;
            if (hasAddress == 1) {
                count = count + 1;
                [dataSourceArray insertObject:@{@"name" : @"地址", @"tag" : @"7", @"image" : KBUTTONIMAGENAME_7} atIndex:0];
                if (hasMark == 1) {
                    count = count + 1;
                    [dataSourceArray insertObject:@{@"name" : @"备忘", @"tag" : @"8", @"image" : KBUTTONIMAGENAME_8} atIndex:1];
                    [dataSourceArray insertObject:@{@"name" : @"更多", @"tag" : @"1001", @"image" : KBUTTONIMAGENAME_1001} atIndex:3];
                    [dataSourceArray insertObject:@{@"name" : @"返回", @"tag" : @"1002", @"image" : KBUTTONIMAGENAME_1002} atIndex:4];

                    if (hasPhoneNumber == 1) {
                        count = count + 1;
                        [dataSourceArray insertObject:@{@"name" : @"联系人", @"tag" : @"9", @"image" : KBUTTONIMAGENAME_9} atIndex:5];
                    } else {
                        
                    }
                } else {
                    if (hasPhoneNumber == 1) {
                        count = count + 1;
                        [dataSourceArray insertObject:@{@"name" : @"联系人", @"tag" : @"9", @"image" : KBUTTONIMAGENAME_9} atIndex:2];
                        [dataSourceArray insertObject:@{@"name" : @"更多", @"tag" : @"1001", @"image" : KBUTTONIMAGENAME_1001} atIndex:3];
                        [dataSourceArray insertObject:@{@"name" : @"返回", @"tag" : @"1002", @"image" : KBUTTONIMAGENAME_1002} atIndex:4];
                        
                    } else {
                        
                    }
                }
            } else {
                if (hasMark == 1) {
                    count = count + 1;
                    [dataSourceArray insertObject:@{@"name" : @"备忘", @"tag" : @"8", @"image" : KBUTTONIMAGENAME_8} atIndex:0];
                    if (hasPhoneNumber == 1) {
                        count = count + 1;
                        [dataSourceArray insertObject:@{@"name" : @"联系人", @"tag" : @"9", @"image" : KBUTTONIMAGENAME_9} atIndex:2];
                        [dataSourceArray insertObject:@{@"name" : @"更多", @"tag" : @"1001", @"image" : KBUTTONIMAGENAME_1001} atIndex:3];
                        [dataSourceArray insertObject:@{@"name" : @"返回", @"tag" : @"1002", @"image" : KBUTTONIMAGENAME_1002} atIndex:4];
                    } else {
                        
                    }
                } else {
                    if (hasPhoneNumber == 1) {
                        count = count + 1;
                        [dataSourceArray insertObject:@{@"name" : @"联系人", @"tag" : @"9", @"image" : KBUTTONIMAGENAME_9} atIndex:1];
                    } else {
                        
                    }
                }
            }
            
        } else {
            //待接收状态  二级菜单。接受, 拒绝
            count = 2;
            [dataSourceArray addObject:@{@"name" : @"接受", @"tag" : @"4", @"image" : KBUTTONIMAGENAME_4}];
            [dataSourceArray addObject:@{@"name" : @"拒绝", @"tag" : @"5", @"image" : KBUTTONIMAGENAME_5}];
        }
    } else if ([[item objectForKey:@"flag"] isEqualToString:@"tasks"]) {
        // 任务  1完成 2延时 3删除 4接受 5拒绝  6退出  地址7 备忘8 联系人9
        _dataType = DataSourceTypeTask;
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"createdBy"]]) {
            NSDictionary *createDict = [NSDictionary dictionaryWithDictionary:[item objectForKey:@"createdBy"]];
            creatId = [[createDict safeObjectForKey:@"id"] integerValue];
        }
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"owner"]]) {
            NSDictionary *createDict = [NSDictionary dictionaryWithDictionary:[item objectForKey:@"owner"]];
            ownerId = [[createDict safeObjectForKey:@"id"] integerValue];
        }
        taskStatus = [[item safeObjectForKey:@"taskStatus"] integerValue];
        NSLog(@"=====当前用户=====%@", appDelegateAccessor.moudle.userId);
        // 创建人  完成 延时  删除
        // 负责人  完成 延时   / 接受  拒绝
        // 参与人  退出
        // 任务  1完成 2延时 3删除 4接受 5拒绝  6退出  地址7 备忘8 联系人9
        if (creatId == [appDelegateAccessor.moudle.userId integerValue]) {
            // 完成 延时 删除
            count = 3;
            [dataSourceArray addObject:@{@"name" : @"完成", @"tag" : @"1", @"image" : KBUTTONIMAGENAME_11}];
            [dataSourceArray addObject:@{@"name" : @"延时", @"tag" : @"2", @"image" : KBUTTONIMAGENAME_2}];
            [dataSourceArray addObject:@{@"name" : @"删除", @"tag" : @"3", @"image" : KBUTTONIMAGENAME_3}];
            if (hasAddress == 1) {
                count = count + 1;
                [dataSourceArray insertObject:@{@"name" : @"地址", @"tag" : @"7", @"image" : KBUTTONIMAGENAME_7} atIndex:0];
                if (hasMark == 1) {
                    count = count + 1;
                    [dataSourceArray insertObject:@{@"name" : @"备忘", @"tag" : @"8", @"image" : KBUTTONIMAGENAME_8} atIndex:1];
                    [dataSourceArray insertObject:@{@"name" : @"更多", @"tag" : @"1001", @"image" : KBUTTONIMAGENAME_1001} atIndex:3];
                    [dataSourceArray insertObject:@{@"name" : @"返回", @"tag" : @"1002", @"image" : KBUTTONIMAGENAME_1002} atIndex:4];
                    
                    if (hasPhoneNumber == 1) {
                        count = count + 1;
                        [dataSourceArray insertObject:@{@"name" : @"联系人", @"tag" : @"9", @"image" : KBUTTONIMAGENAME_9} atIndex:5];
                    } else {
                        
                    }
                } else {
                    if (hasPhoneNumber == 1) {
                        count = count + 1;
                        [dataSourceArray insertObject:@{@"name" : @"联系人", @"tag" : @"9", @"image" : KBUTTONIMAGENAME_9} atIndex:2];
                        [dataSourceArray insertObject:@{@"name" : @"更多", @"tag" : @"1001", @"image" : KBUTTONIMAGENAME_1001} atIndex:3];
                        [dataSourceArray insertObject:@{@"name" : @"返回", @"tag" : @"1002", @"image" : KBUTTONIMAGENAME_1002} atIndex:4];
                        
                    } else {
                        
                    }
                }
            } else {
                if (hasMark == 1) {
                    count = count + 1;
                    [dataSourceArray insertObject:@{@"name" : @"备忘", @"tag" : @"8", @"image" : KBUTTONIMAGENAME_8} atIndex:0];
                    if (hasPhoneNumber == 1) {
                        count = count + 1;
                        [dataSourceArray insertObject:@{@"name" : @"联系人", @"tag" : @"9", @"image" : KBUTTONIMAGENAME_9} atIndex:2];
                        [dataSourceArray insertObject:@{@"name" : @"更多", @"tag" : @"1001", @"image" : KBUTTONIMAGENAME_1001} atIndex:3];
                        [dataSourceArray insertObject:@{@"name" : @"返回", @"tag" : @"1002", @"image" : KBUTTONIMAGENAME_1002} atIndex:4];
                    } else {
                        
                    }
                } else {
                    if (hasPhoneNumber == 1) {
                        count = count + 1;
                        [dataSourceArray insertObject:@{@"name" : @"联系人", @"tag" : @"9", @"image" : KBUTTONIMAGENAME_9} atIndex:1];
                    } else {
                        
                    }
                }
            }

        } else {
            if (ownerId == [appDelegateAccessor.moudle.userId integerValue] && taskStatus == 1) {
                // 接受 拒绝
                taskType = 1;
                count = 2;
                [dataSourceArray addObject:@{@"name" : @"接受", @"tag" : @"4", @"image" : KBUTTONIMAGENAME_4}];
                [dataSourceArray addObject:@{@"name" : @"拒绝", @"tag" : @"5", @"image" : KBUTTONIMAGENAME_5}];
            } else if (ownerId == [appDelegateAccessor.moudle.userId integerValue] && taskStatus != 1) {
                // 完成 延时
                taskType = 0;
                count = 2;
                [dataSourceArray addObject:@{@"name" : @"完成", @"tag" : @"1", @"image" : KBUTTONIMAGENAME_11}];
                [dataSourceArray addObject:@{@"name" : @"延时", @"tag" : @"2", @"image" : KBUTTONIMAGENAME_2}];
            } else {
                //退出
                count = 1;
                [dataSourceArray addObject:@{@"name" : @"退出", @"tag" : @"6", @"image" : KBUTTONIMAGENAME_6}];
            }
        }
    } else {
        NSLog(@"预留");
    }
    flagForShowOrHidden = flagStr;
    [self setDefaultValue:[item objectForKey:@"flag"] WithCount:count];
    [self setCellViewShowByCount:count withType:[item objectForKey:@"flag"]];
    [self addClickEventForCellView];
    
    
}

///按钮添加点击事件
///btn tag规则
/// 1 2 3 4
/// 1 2 3 1001
/// 1002 4 5 6

-(void)addClickEventForCellView {
    [self.btn1 addTarget:self action:@selector(menuBtnClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn2 addTarget:self action:@selector(menuBtnClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn3 addTarget:self action:@selector(menuBtnClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn4 addTarget:self action:@selector(menuBtnClickEvent:) forControlEvents:UIControlEventTouchUpInside];
}



///菜单中按钮点击事件
-(void)menuBtnClickEvent:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    ///更多按钮
    if (tag == 1001) {
        [self moveToRight:flagForShowOrHidden];
    }else if (tag == 1002){
        ///返回按钮
        [self moveToLeft];
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickMenuItemEvent:withDataType:withDataId:)]) {
            [self.delegate clickMenuItemEvent:btn.tag withDataType:_dataType withDataId:_dataId];
        }
    }
}

///更多
-(void)moveToRight:(NSString *)flag{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.7f;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [self.layer addAnimation:transition forKey:@"animation"];
    //如果触发了这个方法，那么 "返回" 必然是存在的
    [self setCellViewHide:YES];
    NSDictionary *dict = [NSDictionary dictionary];
    for (int i = 4; i < dataSourceArray.count; i++) {
        dict = dataSourceArray[i];
        switch (i - 4) {
            case 0:
            {
                self.label1.text = [dict objectForKey:@"name"];
                self.btn1.tag = [[dict objectForKey:@"tag"] integerValue];
                [self.btn1 setImage:[UIImage imageNamed:[dict objectForKey:@"image"]] forState:UIControlStateNormal];
                self.label1.hidden = NO;
                self.btn1.hidden = NO;
            }
                break;
            case 1:
            {
                self.label2.text = [dict objectForKey:@"name"];
                self.btn2.tag = [[dict objectForKey:@"tag"] integerValue];
                [self.btn2 setImage:[UIImage imageNamed:[dict objectForKey:@"image"]] forState:UIControlStateNormal];
                self.label2.hidden = NO;
                self.btn2.hidden = NO;
            }
                
                break;
            case 2:
            {
                self.label3.text = [dict objectForKey:@"name"];
                self.btn3.tag = [[dict objectForKey:@"tag"] integerValue];
                [self.btn3 setImage:[UIImage imageNamed:[dict objectForKey:@"image"]] forState:UIControlStateNormal];
                self.label3.hidden = NO;
                self.btn3.hidden = NO;
            }
                break;
            case 3:
            {
                self.label4.text = [dict objectForKey:@"name"];
                self.btn4.tag = [[dict objectForKey:@"tag"] integerValue];
                [self.btn4 setImage:[UIImage imageNamed:[dict objectForKey:@"image"]] forState:UIControlStateNormal];
                self.label4.hidden = NO;
                self.btn4.hidden = NO;
            }
                break;
            default:
                break;
        }
        
    }

}

-(void)setDefaultValue:(NSString *)flag WithCount:(NSInteger)count{
    //tag
    // 任务  1完成 2延时 3删除 4接受 5拒绝  6退出  地址7 备忘8 联系人9
    // 日程  1下一步 2延时 3删除 4接受 5拒绝 6退出  地址7 备忘8 联系人9
    
    [self  setCellViewHide:YES];
    NSDictionary *dict = [NSDictionary dictionary];
    for (int i = 0; i < count; i++) {
        dict = dataSourceArray[i];
        switch (i) {
            case 0:
            {
                self.label1.text = [dict objectForKey:@"name"];
                self.btn1.tag = [[dict objectForKey:@"tag"] integerValue];
                [self.btn1 setImage:[UIImage imageNamed:[dict objectForKey:@"image"]] forState:UIControlStateNormal];
                self.label1.hidden = NO;
                self.btn1.hidden = NO;
            }
                break;
            case 1:
            {
                self.label2.text = [dict objectForKey:@"name"];
                self.btn2.tag = [[dict objectForKey:@"tag"] integerValue];
                [self.btn2 setImage:[UIImage imageNamed:[dict objectForKey:@"image"]] forState:UIControlStateNormal];
                self.label2.hidden = NO;
                self.btn2.hidden = NO;
            }
                
                break;
            case 2:
            {
                self.label3.text = [dict objectForKey:@"name"];
                self.btn3.tag = [[dict objectForKey:@"tag"] integerValue];
                [self.btn3 setImage:[UIImage imageNamed:[dict objectForKey:@"image"]] forState:UIControlStateNormal];
                self.label3.hidden = NO;
                self.btn3.hidden = NO;
            }
                
                break;
            case 3:
            {
                self.label4.text = [dict objectForKey:@"name"];
                self.btn4.tag = [[dict objectForKey:@"tag"] integerValue];
                [self.btn4 setImage:[UIImage imageNamed:[dict objectForKey:@"image"]] forState:UIControlStateNormal];
                self.label4.hidden = NO;
                self.btn4.hidden = NO;
            }
                break;
            default:
                break;
        }
        
    }

    /*
    if ([flag isEqualToString:@"schedules"]) {
        if (count == 1) {

        } else if (count == 2) {
            self.label1.text = @"接受";
            self.btn1.tag = 4;
            self.label2.text = @"拒绝";
            self.btn2.tag = 5;
            [self.btn1 setImage:[UIImage imageNamed:KBUTTONIMAGENAME_7] forState:UIControlStateNormal];
            [self.btn2 setImage:[UIImage imageNamed:KBUTTONIMAGENAME_8] forState:UIControlStateNormal];
        } else {
            NSDictionary *dict = [NSDictionary dictionary];
            for (int i = 0; i < count; i++) {
                dict = dataSourceArray[i];
                switch (i) {
                    case 0:
                    {
                        self.label1.text = [dict objectForKey:@"name"];
                        self.btn1.tag = [[dict objectForKey:@"tag"] integerValue];
                    }
                        break;
                    case 1:
                    {
                        self.label2.text = [dict objectForKey:@"name"];
                        self.btn2.tag = [[dict objectForKey:@"tag"] integerValue];
                    }

                        break;
                    case 2:
                    {
                        self.label3.text = [dict objectForKey:@"name"];
                        self.btn3.tag = [[dict objectForKey:@"tag"] integerValue];
                    }
 
                        break;
                    case 3:
                    {
                        self.label4.text = [dict objectForKey:@"name"];
                        self.btn4.tag = [[dict objectForKey:@"tag"] integerValue];
                    }
                        break;
                default:
                    break;
                }

            }
        }
    } else {
        if (count == 1) {
            self.btn1.tag = 6;
            self.label1.text = @"退出";
            [self.btn1 setImage:[UIImage imageNamed:KBUTTONIMAGENAME_9] forState:UIControlStateNormal];
        } else if (count == 2) {
            if (taskType == 1) {
                self.label1.text = @"接受";
                self.btn1.tag = 4;
                self.label2.text = @"拒绝";
                self.btn2.tag = 5;
                [self.btn1 setImage:[UIImage imageNamed:KBUTTONIMAGENAME_7] forState:UIControlStateNormal];
                [self.btn2 setImage:[UIImage imageNamed:KBUTTONIMAGENAME_8] forState:UIControlStateNormal];
            } else {
                self.btn1.tag = 1;
                self.label1.text = @"完成";
                self.btn2.tag = 2;
                self.label2.text = @"延时";
                [self.btn1 setImage:[UIImage imageNamed:KBUTTONIMAGENAME_11] forState:UIControlStateNormal];
                [self.btn2 setImage:[UIImage imageNamed:KBUTTONIMAGENAME_5] forState:UIControlStateNormal];
            }
        } else {
            self.btn1.tag = 1;
            self.label1.text = @"完成";
            self.btn2.tag = 2;
            self.label2.text = @"延时";
            self.btn3.tag = 3;
            self.label3.text = @"删除";
            [self.btn1 setImage:[UIImage imageNamed:KBUTTONIMAGENAME_11] forState:UIControlStateNormal];
            [self.btn2 setImage:[UIImage imageNamed:KBUTTONIMAGENAME_5] forState:UIControlStateNormal];
            [self.btn3 setImage:[UIImage imageNamed:KBUTTONIMAGENAME_6] forState:UIControlStateNormal];
        }
    }
     */
}

///返回
-(void)moveToLeft{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.7f;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [self.layer addAnimation:transition forKey:@"animation"];
    
    [self setCellViewHide:NO];
    NSDictionary *dict = [NSDictionary dictionary];
    for (int i = 0; i < dataSourceArray.count; i++) {
        dict = dataSourceArray[i];
        switch (i) {
            case 0:
            {
                self.label1.text = [dict objectForKey:@"name"];
                self.btn1.tag = [[dict objectForKey:@"tag"] integerValue];
                [self.btn1 setImage:[UIImage imageNamed:[dict objectForKey:@"image"]] forState:UIControlStateNormal];
            }
                break;
            case 1:
            {
                self.label2.text = [dict objectForKey:@"name"];
                self.btn2.tag = [[dict objectForKey:@"tag"] integerValue];
                [self.btn2 setImage:[UIImage imageNamed:[dict objectForKey:@"image"]] forState:UIControlStateNormal];
            }
                
                break;
            case 2:
            {
                self.label3.text = [dict objectForKey:@"name"];
                self.btn3.tag = [[dict objectForKey:@"tag"] integerValue];
                [self.btn3 setImage:[UIImage imageNamed:[dict objectForKey:@"image"]] forState:UIControlStateNormal];
            }
                
                break;
            case 3:
            {
                self.label4.text = [dict objectForKey:@"name"];
                self.btn4.tag = [[dict objectForKey:@"tag"] integerValue];
                [self.btn4 setImage:[UIImage imageNamed:[dict objectForKey:@"image"]] forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
        
    }

}

-(void)setCellViewShowByCount:(NSInteger)count withType:(NSString *)type{
    [self setCellViewHide:YES];
    NSLog(@"%ld", count);
    if (count > 0) {
        self.btn1.hidden = NO;
        self.label1.hidden = NO;
    }
    
    if (count > 1) {
        self.btn2.hidden = NO;
        self.label2.hidden = NO;
    }
    
    if (count > 2) {
        self.btn3.hidden = NO;
        self.label3.hidden = NO;
    }
    
    if (count > 3) {
        self.btn4.hidden = NO;
        self.label4.hidden = NO;
    }
}

-(void)setCellViewHide:(BOOL) isHide{
    self.btn1.hidden = isHide;
    self.label1.hidden = isHide;
    self.btn2.hidden = isHide;
    self.label2.hidden = isHide;
    self.btn3.hidden = isHide;
    self.label3.hidden = isHide;
    self.btn4.hidden = isHide;
    self.label4.hidden = isHide;
}


-(void)setCellFrame{
    CGFloat width = kScreen_Width/4;
    CGFloat heightBtn = 50;
    CGFloat heightLabel = 20;
    CGFloat vYLabel = 29;
    self.btn1.frame = CGRectMake(0, 0, width, heightBtn);
    self.label1.frame = CGRectMake(0, vYLabel, width, heightLabel);
    
    self.btn2.frame = CGRectMake(width, 0, width, heightBtn);
    self.label2.frame = CGRectMake(width, vYLabel, width, heightLabel);
    
    self.btn3.frame = CGRectMake(width*2, 0, width, heightBtn);
    self.label3.frame = CGRectMake(width*2, vYLabel, width, heightLabel);
    
    self.btn4.frame = CGRectMake(width*3, 0, width, heightBtn);
    self.label4.frame = CGRectMake(width*3, vYLabel, width, heightLabel);
}

- (void)customButton:(NSInteger)count {
    for (int i = 0; i < count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(KBUTTONSIZEWIDTH * i, KBUTTONSIZEWIDTH, 0, KBUTTONSIZEHIGTH);
        button.tag = i;
        button.backgroundColor = [UIColor redColor];
        [self.bgView addSubview:button];
    }
}

@end
