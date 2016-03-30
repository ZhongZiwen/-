//
//  LLCenterPickerView.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "LLCenterPickerView.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"

@interface LLCenterPickerView (){
    NSString *timeForamt;
}
@end

@implementation LLCenterPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCurDate:(NSDate *)curDate andMinDate:(NSDate *)minDate headTitle:(NSString *)headTitle dateType:(NSInteger)type{
    self = [super init];
    if(self){
        self.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT);
        self.backgroundColor = RGBACOLOR(160, 160, 160, 0);
        
         menuView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_BOUNDS_HEIGHT, DEVICE_BOUNDS_WIDTH, 250)];
        
        if (headTitle && headTitle.length > 0) {
            UILabel *lableHeadTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 40)];
            lableHeadTitle.backgroundColor = [UIColor whiteColor];
            lableHeadTitle.font = [UIFont systemFontOfSize:17.0];
            lableHeadTitle.textColor = COLOR_LIGHT_BLUE;
            lableHeadTitle.textAlignment = NSTextAlignmentCenter;
            lableHeadTitle.text = headTitle;
            [menuView addSubview:lableHeadTitle];
        }
        
        UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSave.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-80, 0, 80, 40);
        [btnSave setTitle:@"确定" forState:UIControlStateNormal];
        [btnSave setTitleColor:COLOR_LIGHT_BLUE forState:UIControlStateNormal];
        btnSave.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [btnSave addTarget:self action:@selector(saveEvent) forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:btnSave];
        
        
        _datePickView = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 40, DEVICE_BOUNDS_WIDTH, 250-40)];
        _datePickView.backgroundColor = [UIColor grayColor];
        
        timeForamt = @"HH:mm";
        if (type == 0) {
            _datePickView.datePickerMode = UIDatePickerModeTime;
        }else if (type == 1){
            _datePickView.datePickerMode = UIDatePickerModeDate;
        }else if (type == 2){
            _datePickView.datePickerMode =UIDatePickerModeDateAndTime;
        }else if (type == 3){
             _datePickView.datePickerMode = UIDatePickerModeTime;
            timeForamt = @"yyyy-MM-dd HH:mm";
        }
        
        
        if (minDate) {
            NSLog(@"--minDate:%@",minDate);
            NSTimeZone *timeZone=[NSTimeZone systemTimeZone];
            NSInteger seconds=[timeZone secondsFromGMTForDate:minDate];
            NSDate *newDate=[minDate dateByAddingTimeInterval:-seconds];
            NSLog(@"--newDate:%@",newDate);
            _datePickView.minimumDate = newDate;
            _datePickView.date = newDate;
        }else{
            if (curDate) {
                _datePickView.date = curDate;
            }else{
                _datePickView.date = [NSDate date];
            }
            
        }
        
        _datePickView.maximumDate = nil;
        [_datePickView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [menuView addSubview:_datePickView];
        
        
        [self addSubview:menuView];
        [self animeData];
    }
    return self;
}


-(void)animeData{
    //self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
    [self addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    [UIView animateWithDuration:.25 animations:^{
        self.backgroundColor = RGBACOLOR(160, 160, 160, .4);
        [UIView animateWithDuration:.25 animations:^{
            [menuView setFrame:CGRectMake(menuView.frame.origin.x, DEVICE_BOUNDS_HEIGHT-menuView.frame.size.height, menuView.frame.size.width, menuView.frame.size.height)];
        }];
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([touch.view isKindOfClass:[self class]]){
        return YES;
    }
    return NO;
}

-(void)tappedCancel{
    [UIView animateWithDuration:.25 animations:^{
        [menuView setFrame:CGRectMake(0, DEVICE_BOUNDS_HEIGHT,DEVICE_BOUNDS_WIDTH, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

///底部按钮事件
-(void)eventOfFootBtn:(id)sender{
    [self tappedCancel];
}

- (void)showInView:(UIViewController *)Sview
{
    if(Sview==nil){
        [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
    }else{
        //[view addSubview:self];
        [Sview.view addSubview:self];
    }

}


#pragma mark - 多选保存操作
-(void)saveEvent{
    [self tappedCancel];
    if (self.selectedDateBlock) {
        self.selectedDateBlock(selectDateTime,curSelectDate);
    }
}


-(void)dateChanged:(id)sender{
    NSDate *date= [(UIDatePicker *)sender date];
    
    

    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    formatter.dateFormat=timeForamt;
    selectDateTime = [formatter stringFromDate:date];
    NSLog(@"selectDateTime----%@",selectDateTime);
    
    
    NSTimeZone *timeZone=[NSTimeZone systemTimeZone];
    NSInteger seconds=[timeZone secondsFromGMTForDate:date];
    curSelectDate=[date dateByAddingTimeInterval:seconds];
    NSLog(@"curSelectDate----%@",curSelectDate);
    
}

@end
