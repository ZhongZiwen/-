//
//  CRM_ScheduleNewViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CRM_ScheduleNewViewController.h"
#import "AddressSelectedController.h"
#import "ExportAddressViewController.h"
#import "EditAddressViewController.h"
#import "ScheduleTypeViewController.h"
#import "DateAndTimeValueTrasformer.h"
#import <XLForm.h>
#import "XLFScheduleThemeCell.h"
#import "ScheduleType.h"
#import "ExportAddress.h"

@interface CRM_ScheduleNewViewController ()

@end

@implementation CRM_ScheduleNewViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(backButtonItemPress)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"创建" target:self action:@selector(rightButtonItemPress)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    // 日程名称
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"title" rowType:XLFormRowDescriptorTypeScheduleTheme];
    row.selectorTitle = @"选择类型";
    row.value = [[ScheduleType alloc] init];
    row.action.formBlock = ^(XLFormRowDescriptor *descriptor) {
        ScheduleTypeViewController *typeController = [[ScheduleTypeViewController alloc] init];
        typeController.title = @"选择类型";
        typeController.item = descriptor.value;
        typeController.valueBlock = ^(ScheduleType *item) {
            XLFormRowDescriptor *myRow = [self.form formRowWithTag:@"title"];
            myRow.value = item;
            [self updateFormRow:myRow];
        };
        [self.navigationController pushViewController:typeController animated:YES];
    };
    [section addFormRow:row];
    
    // 全天、开始、结束
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"allDay" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"全天"];
    row.value = @NO;
    [section addFormRow:row];
    
    NSDate *currentDate = [NSDate new];
    NSInteger hour = [currentDate hour];
    NSInteger minute = [currentDate minute];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"starts" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"开始"];
    if (minute < 30) {
        row.value = [NSDate dateWithHour:hour + 1 minute:0];
    }
    else {
        row.value = [NSDate dateWithHour:hour + 1 minute:30];
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"ends" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"结束"];
    if (minute < 30) {
        row.value = [NSDate dateWithHour:hour + 1 minute:30];
    }
    else {
        row.value = [NSDate dateWithHour:hour + 2 minute:0];
    }
    [section addFormRow:row];
    
//    // 私密
//    section = [XLFormSectionDescriptor formSection];
//    [form addFormSection:section];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"private" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"私密"];
//    [row.cellConfig setObject:[UIFont systemFontOfSize:12] forKey:@"detailTextLabel.font"];
//    [row.cellConfig setObject:@(NSTextAlignmentLeft) forKey:@"detailTextLabel.textAlignment"];
//    [row.cellConfig setObject:@"仅参与人和上级可见                  " forKey:@"detailTextLabel.text"];
//    row.value = @NO;
//    [section addFormRow:row];
    
    // 更多详细信息
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"添加参与人、关联业务、重复和提醒等信息";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"more" rowType:XLFormRowDescriptorTypeButton title:@"+更多详细信息"];
    [row.cellConfig setObject:[UIColor blackColor] forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:14] forKey:@"textLabel.font"];
    row.action.formSelector = @selector(didTouchButton:);
    [section addFormRow:row];
    
    self.form = form;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)backButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemPress {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    
    XLFormRowDescriptor *row;
    
    row = [self.form formRowWithTag:@"title"];
    ScheduleType *item = row.value;
    if (item.title) {
        [params setObject:item.title forKey:@"content"];
    }else {
        [NSObject showHudTipStr:@"请填写日程名称"];
        return;
    }
    if ([item formValue]) {
        [params setObject:[item formValue] forKey:@"scheduleType"];
    }else {
        [NSObject showHudTipStr:@"请选择日程类型"];
        return;
    }
    
    row = [self.form formRowWithTag:@"allDay"];
    ///fullday修改为isAllDay
    [params setObject:@(![row.value integerValue]) forKey:@"isAllDay"];
    
    row = [self.form formRowWithTag:@"starts"];
    [params setObject:[row.value stringTimestamp] forKey:@"startDate"];
    
    row = [self.form formRowWithTag:@"ends"];
    [params setObject:[row.value stringTimestamp] forKey:@"endDate"];
    
//    row = [self.form formRowWithTag:@"private"];
//    [params setObject:@(![row.value integerValue]) forKey:@"privateFlag"];
    [params setObject:@1 forKey:@"privateFlag"];
    
    row = [self.form formRowWithTag:@"attend"];
    if (row) {
        if (![row.value formValue]) {
            [NSObject showHudTipStr:@"参与人不能为空"];
            return;
        }
        [params setObject:[row.value formValue] forKey:@"staffIds"];
    }
    else {
        [params setObject:appDelegateAccessor.moudle.userId forKey:@"staffIds"];
    }

    
    // 重复
//    row = [self.form formRowWithTag:@"repeat"];
//    NSInteger isRepeat = 1;
//    NSInteger repeatType = -1;
//    switch ([[row.value formValue] integerValue]) {
//        case 1: {
//            isRepeat = 1;
//            repeatType = -1;
//        }
//            break;
//        case 2: {
//            isRepeat = 0;
//            repeatType = 1;
//        }
//            break;
//        case 3: {
//            isRepeat = 0;
//            repeatType = 2;
//        }
//            break;
//        case 4: {
//            isRepeat = 0;
//            repeatType = 3;
//        }
//            break;
//        default:
//            break;
//    }
//    [params setObject:@(isRepeat) forKey:@"isRepeat"];
//    [params setObject:@(repeatType) forKey:@"repeatType"];
    [params setObject:@1 forKey:@"isRepeat"];
    [params setObject:@-1 forKey:@"repeatType"];
    
    row = [self.form formRowWithTag:@"remind"];
    [params setObject:([row.value formValue] ? : @2) forKey:@"remindType"];
    
    row = [self.form formRowWithTag:@"remark"];
    [params setObject:(row.value ? : @"") forKey:@"remark"];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Common_CreateTaskSchedule_WithParams:params path:_requestPath block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)didTouchButton:(XLFormRowDescriptor*)sender {
    [self.form removeFormSection:[[self.form formSections] lastObject]];
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    // 参与人
    AddressBook *item = [[AddressBook alloc] init];
    item.id = @([appDelegateAccessor.moudle.userId integerValue]);
    item.name = appDelegateAccessor.moudle.userName;
    ExportAddress *exportAddress = [[ExportAddress alloc] init];
    [exportAddress.selectedArray addObject:item];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"attend" rowType:XLFormRowDescriptorTypeSelectorPush title:@"参与人"];
    row.noValueDisplayText = @"点击选择(必填)";
    row.selectorTitle = @"编辑参与人";
    row.action.viewControllerClass = [EditAddressViewController class];
    row.value = exportAddress;
    [section addFormRow:row];
    
    // 设置重复
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"repeat" rowType:XLFormRowDescriptorTypeSelectorPush title:@"设置重复"];
//    row.selectorTitle = @"设置重复";
//    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"不重复"];
//    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"不重复"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"每天重复"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"每周重复"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"每月重复"]];
//    [section addFormRow:row];
    
    XLFormRowDescriptor *allDayRow = [self.form formRowWithTag:@"allDay"];
    // 设置提醒
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"remind" rowType:XLFormRowDescriptorTypeSelectorPush title:@"提醒"];
    row.selectorTitle = @"提醒";
    if ([allDayRow.value integerValue]) {
        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(9) displayText:@"当天(上午9点)"];
        row.selectorOptions = [self remindSelectorOptionsWithAllDay:YES];
    }else {
        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"提前10分钟"];
        row.selectorOptions = [self remindSelectorOptionsWithAllDay:NO];
    }
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    // 备注
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"remark" rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"备注" forKey:@"textView.placeholder"];
    [section addFormRow:row];
    [self.form addFormSection:section];
}

- (NSArray*)remindSelectorOptionsWithAllDay:(BOOL)isAllDay {
    if (isAllDay) {
        return @[[XLFormOptionsObject formOptionsObjectWithValue:@(-1) displayText:@"不提醒"],
                 [XLFormOptionsObject formOptionsObjectWithValue:@(9) displayText:@"当天(上午9点)"],
                 [XLFormOptionsObject formOptionsObjectWithValue:@(10) displayText:@"1天前(上午9点)"]];
    }
    
    return @[[XLFormOptionsObject formOptionsObjectWithValue:@(-1) displayText:@"不提醒"],
             [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"准时"],
             [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"提前5分钟"],
             [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"提前10分钟"],
             [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"提前30分钟"],
             [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"提前1小时"],
             [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"提前2小时"],
             [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"提前6小时"],
             [XLFormOptionsObject formOptionsObjectWithValue:@(7) displayText:@"提前1天"],
             [XLFormOptionsObject formOptionsObjectWithValue:@(8) displayText:@"提前2天"]];
}

#pragma mark - XLFormDescriptorDelegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    if ([rowDescriptor.tag isEqualToString:@"allDay"]){
        XLFormRowDescriptor * startDateDescriptor = [self.form formRowWithTag:@"starts"];
        XLFormRowDescriptor * endDateDescriptor = [self.form formRowWithTag:@"ends"];
        XLFormRowDescriptor * remindDescriptor = [self.form formRowWithTag:@"remind"];

        XLFormDateCell * dateStartCell = (XLFormDateCell *)[[self.form formRowWithTag:@"starts"] cellForFormController:self];
        XLFormDateCell * dateEndCell = (XLFormDateCell *)[[self.form formRowWithTag:@"ends"] cellForFormController:self];
        if ([[rowDescriptor.value valueData] boolValue] == YES){
            startDateDescriptor.valueTransformer = [DateValueTrasformer class];
            endDateDescriptor.valueTransformer = [DateValueTrasformer class];
            [dateStartCell setFormDatePickerMode:XLFormDateDatePickerModeDate];
            [dateEndCell setFormDatePickerMode:XLFormDateDatePickerModeDate];
            
            remindDescriptor.value = [XLFormOptionsObject formOptionsObjectWithValue:@(9) displayText:@"当天(上午9点)"];
            remindDescriptor.selectorOptions = [self remindSelectorOptionsWithAllDay:YES];
        }
        else{
            startDateDescriptor.valueTransformer = [DateTimeValueTrasformer class];
            endDateDescriptor.valueTransformer = [DateTimeValueTrasformer class];
            [dateStartCell setFormDatePickerMode:XLFormDateDatePickerModeDateTime];
            [dateEndCell setFormDatePickerMode:XLFormDateDatePickerModeDateTime];
            
            remindDescriptor.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"提前10分钟"];
            remindDescriptor.selectorOptions = [self remindSelectorOptionsWithAllDay:NO];
        }
        [self updateFormRow:startDateDescriptor];
        [self updateFormRow:endDateDescriptor];
        [self updateFormRow:remindDescriptor];
    }
    else if ([rowDescriptor.tag isEqualToString:@"starts"]){
        XLFormRowDescriptor * startDateDescriptor = [self.form formRowWithTag:@"starts"];
        XLFormRowDescriptor * endDateDescriptor = [self.form formRowWithTag:@"ends"];
        if ([startDateDescriptor.value compare:endDateDescriptor.value] == NSOrderedDescending) {
            // startDateDescriptor is later than endDateDescriptor
            endDateDescriptor.value =  [[NSDate alloc] initWithTimeInterval:(60*30) sinceDate:startDateDescriptor.value];
            [endDateDescriptor.cellConfig removeObjectForKey:@"detailTextLabel.attributedText"];
            [self updateFormRow:endDateDescriptor];
        }
    }
    else if ([rowDescriptor.tag isEqualToString:@"ends"]){
        XLFormRowDescriptor * startDateDescriptor = [self.form formRowWithTag:@"starts"];
        XLFormRowDescriptor * endDateDescriptor = [self.form formRowWithTag:@"ends"];
        XLFormDateCell * dateEndCell = (XLFormDateCell *)[endDateDescriptor cellForFormController:self];
        if ([startDateDescriptor.value compare:endDateDescriptor.value] == NSOrderedDescending) {
            // startDateDescriptor is later than endDateDescriptor
            [dateEndCell update]; // force detailTextLabel update
            NSDictionary *strikeThroughAttribute = [NSDictionary dictionaryWithObject:@1
                                                                               forKey:NSStrikethroughStyleAttributeName];
            NSAttributedString* strikeThroughText = [[NSAttributedString alloc] initWithString:dateEndCell.detailTextLabel.text attributes:strikeThroughAttribute];
            [endDateDescriptor.cellConfig setObject:strikeThroughText forKey:@"detailTextLabel.attributedText"];
            [self updateFormRow:endDateDescriptor];
        }
        else{
            [endDateDescriptor.cellConfig removeObjectForKey:@"detailTextLabel.attributedText"];
            [self updateFormRow:endDateDescriptor];
        }
    }
    else if ([rowDescriptor.tag isEqualToString:@"attend"]) {
        if ([rowDescriptor.value formValue]) {
            rowDescriptor.selectorTitle = @"编辑参与人";
            rowDescriptor.action.viewControllerClass = [EditAddressViewController class];
        }else {
            rowDescriptor.selectorTitle = @"选择参与人";
            rowDescriptor.action.viewControllerClass = [ExportAddressViewController class];
        }
    }
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
