//
//  TodayPlanLaterController.m
//  shangketong
//
//  Created by 蒋 on 15/12/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TodayPlanLaterController.h"
#import "DateAndTimeValueTrasformer.h"

@interface TodayPlanLaterController ()

@end

@implementation TodayPlanLaterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonItemPress)];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonItemPress)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    // Do any additional setup after loading the view.
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    NSDate *beginDate = [self getBeginDateWithSting:_startDate];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"starts" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"开始"];
    row.value = beginDate;
    [section addFormRow:row];
    if ([self.title isEqualToString:@"日程延时"]) {
        NSDate *endDate = [self getBeginDateWithSting:_endDate];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"ends" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"结束"];
        row.value = endDate;
        [section addFormRow:row];
    }
    self.form = form;
}
- (void)backButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightButtonItemPress {
    XLFormRowDescriptor *row;
    NSString *startStr, *endStr;
    row = [self.form formRowWithTag:@"starts"];
    startStr = [row.value stringTimestamp];
    NSDate *start = row.value;
    if ([self.title isEqualToString:@"日程延时"]) {
        row = [self.form formRowWithTag:@"ends"];
        endStr = [row.value stringTimestamp];
        NSDate *end = row.value;
        ///计算两个日期的时间差
        NSTimeInterval second = [end timeIntervalSinceDate:start];
        NSLog(@"min:%f",second/60);
        if (second/60 < 0) {
            kShowHUD(@"开始时间应小于结束时间");
            return;
        }else if(second/60 < 30){
            kShowHUD(@"时间间隔不能小于30分钟");
            return;
        }
    }
    
    if (_CommitLaterTimeBlock) {
        _CommitLaterTimeBlock(startStr, endStr);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

///获取开始时间
-(NSDate *)getBeginDateWithSting:(NSString *)string{
    
    NSDate *beginDate;
    ///默认开始时间为下个整点时间，周期30分钟，结束时间即为开始时间+30分
    ///当前时间  30分钟之前 默认下个整点 如2：10  开始3：00  结束 3：30
    ///当前时间  30分钟之后 默认下个整点半 如2：34 开始 3：30  结束 4：00
    NSLog(@"_dateString:%@",string);
    
    NSString *hhmm = [CommonFuntion dateToString:[NSDate date] Format:@"HH:mm"];
    if (string) {
        string = [NSString stringWithFormat:@"%@%@",[string substringToIndex:11],hhmm];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [formatter dateFromString:_startDate];
    
    NSInteger minute = [CommonFuntion getCurDateMinute:[NSDate date]];
    //    NSLog(@"date:%@",date);
    
    if (minute <= 30) {
        beginDate = [NSDate getOneDateHour:1 minute:0 second:0 byDate:date ? date : [NSDate date]];
        beginDate = [NSDate setOneDate:beginDate Minute:0];
    }else{
        beginDate = [NSDate getOneDateHour:1 minute:0 second:0 byDate:date ? date : [NSDate date]];
        beginDate = [NSDate setOneDate:beginDate Minute:30];
    }
    
    return beginDate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
