//
//  CRM_ScheduleNewViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ScheduleNewViewController.h"
#import "AddressSelectedController.h"
#import "ExportAddressViewController.h"
#import "EditAddressViewController.h"
#import "ScheduleTypeViewController.h"
#import "DateAndTimeValueTrasformer.h"
#import <XLForm.h>
#import "XLFScheduleThemeCell.h"
#import "ScheduleType.h"
#import "CommonConstant.h"
#import "AFNHttp.h"
#import "CommonFuntion.h"
#import "NewScheduleEndRepeatViewController.h"
#import "ExportAddress.h"
#import "AddressBook.h"
#import "NSUserDefaults_Cache.h"
#import "XLFSelectorTextDetailCell.h"
#import "RelatedBusinessController.h"
#import "XLFormCustomTextViewCell.h"

@interface ScheduleNewViewController ()

@property (nonatomic, copy) void(^RefreshBussineBlock)(NSDictionary *);
@end

@implementation ScheduleNewViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonItemPress)];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonItemPress)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    //关联业务
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRefresh:) name:@"relatedBusiness" object:nil];
}
- (void)notificationRefresh:(NSNotification *)notification {
    if (_RefreshBussineBlock) {
        _RefreshBussineBlock([notification object]);
    }
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
    
//    @property (strong, nonatomic) NSNumber *id;
//    @property (strong, nonatomic) NSNumber *color;
//    @property (copy, nonatomic) NSString *name;
//    @property (copy, nonatomic) NSString *title;
    
    ScheduleType *otherType = [[ScheduleType alloc] init];
    otherType.id = @0;
    otherType.color = @5;
    otherType.name = @"其他";
    otherType.title = @"";
    
    row.value = otherType;
    row.action.formBlock = ^(XLFormRowDescriptor *descriptor) {
        ScheduleTypeViewController *typeController = [[ScheduleTypeViewController alloc] init];
        typeController.title = @"选择类型";
        typeController.item = descriptor.value;
        typeController.valueBlock = ^(ScheduleType *item) {
            XLFormRowDescriptor *myRow = [self.form formRowWithTag:@"title"];
            NSLog(@"name:%@",item.name);
            NSLog(@"title:%@",item.title);
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
    
    
    NSDate *beginDate = [self getBeginDate];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"starts" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"开始"];
    row.value = beginDate;
    row.valueTransformer = [DateTimeValueTrasformer class];
    //    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"ends" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"结束"];
//    row.value = [NSDate dateWithTimeIntervalSinceNow:60*30];
    row.value = [NSDate getOneDateHour:0 minute:30 second:0 byDate:beginDate];
    row.valueTransformer = [DateTimeValueTrasformer class];
    //    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*25];
    [section addFormRow:row];
    
    /*
    // 私密
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"private" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"私密"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:12] forKey:@"detailTextLabel.font"];
    [row.cellConfig setObject:@(NSTextAlignmentLeft) forKey:@"detailTextLabel.textAlignment"];
    [row.cellConfig setObject:@"仅参与人和上级可见                  " forKey:@"detailTextLabel.text"];
    row.value = @NO;
    [section addFormRow:row];
    */
    
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

///获取开始时间
-(NSDate *)getBeginDate{
    
    NSDate *beginDate;
    ///默认开始时间为下个整点时间，周期30分钟，结束时间即为开始时间+30分
    ///当前时间  30分钟之前 默认下个整点 如2：10  开始3：00  结束 3：30
    ///当前时间  30分钟之后 默认下个整点半 如2：34 开始 3：30  结束 4：00
    NSLog(@"_dateString:%@",_dateString);
    
    NSString *hhmm = [CommonFuntion dateToString:[NSDate date] Format:@"HH:mm"];
    if (_dateString) {
        _dateString = [NSString stringWithFormat:@"%@%@",[_dateString substringToIndex:11],hhmm];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [formatter dateFromString:_dateString];
    
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

///初始化默认参与人
-(AddressBook *)getDefaultAttentPeople{
    AddressBook *user = [[AddressBook alloc] init];
    if (self.userId == [appDelegateAccessor.moudle.userId integerValue]) {
        NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
        user.id = [NSNumber numberWithLong:[[userInfo safeObjectForKey:@"id"] longLongValue]];
        user.name = [userInfo safeObjectForKey:@"name"];
        user.icon = [userInfo safeObjectForKey:@"icon"];
    }else{
        user.id = [NSNumber numberWithInteger:self.userId];
        user.name = self.userName;
        user.icon = self.userIcon;
    }
    NSLog(@"user.name:%@",user.name);
    return user;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)backButtonItemPress {
    [self leftButtonPress];
}

- (void)rightButtonItemPress {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    
    XLFormRowDescriptor *row;
    
    row = [self.form formRowWithTag:@"title"];
    ScheduleType *item = row.value;
    if (item.title && ![CommonFuntion isEmptyString:item.title]) {
        [params setObject:item.title forKey:@"content"];
    }else {
        kShowHUD(@"请填写日程名称");
        return;
    }
    if ([item formValue]) {
        [params setObject:[item formValue] forKey:@"scheduleType"];
    }else {
        kShowHUD(@"请选择日程类型");
        return;
    }
    
    BOOL isAllDay = FALSE;
    row = [self.form formRowWithTag:@"allDay"];
    [params setObject:@(![row.value integerValue]) forKey:@"isAllDay"];
    if ([row.value boolValue]) {
        isAllDay = TRUE;
    }else{
        isAllDay = FALSE;
    }
    
    row = [self.form formRowWithTag:@"starts"];
    [params setObject:[row.value stringTimestamp] forKey:@"startDate"];
    NSDate *start = row.value;
    row = [self.form formRowWithTag:@"ends"];
    [params setObject:[row.value stringTimestamp] forKey:@"endDate"];
    NSDate *end = row.value;
    
    
    if (isAllDay) {
    }else{
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
    
    
//    row = [self.form formRowWithTag:@"private"];
//    [params setObject:@(![row.value integerValue]) forKey:@"privateFlag"];
    
    row = [self.form formRowWithTag:@"attend"];
    [params setObject:([row.value formValue] ? [row.value formValue]:[NSString stringWithFormat:@"%ti",self.userId] ) forKey:@"staffIds"];
    
    row = [self.form formRowWithTag:@"repeat"];
    NSInteger isRepeat = 1;
    NSInteger repeatType = -1;
    switch ([[row.value formValue] integerValue]) {
        case 1: {
            isRepeat = 1;
            repeatType = -1;
        }
            break;
        case 2: {
            isRepeat = 0;
            repeatType = 1;
        }
            break;
        case 3: {
            isRepeat = 0;
            repeatType = 2;
        }
            break;
        case 4: {
            isRepeat = 0;
            repeatType = 3;
        }
            break;
        default:
            break;
    }
    [params setObject:@(isRepeat) forKey:@"isRepeat"];
    [params setObject:@(repeatType) forKey:@"repeatType"];
    
    row = [self.form formRowWithTag:@"endRepeat"];
    if (row) {
        //下面两个字段如果在不重复的情况下不传。
        ///repeatEndType结束重复类型：1永不结束；2按日期结束
        ///repeatEndTime按日期结束的结束如期。
        
        NSLog(@"endRepeat = %@", [row.value formValue]);
        NSString *endrepeat = [row.value formValue];
        if ([[params objectForKey:@"isRepeat"] integerValue] == 0) {
            if (endrepeat == nil || [endrepeat isEqualToString:@"永不结束"]) {
                [params setObject:[NSNumber numberWithInt:1] forKey:@"repeatEndType"];
                [params setObject:@"" forKey:@"repeatEndTime"];
            }else{
                [params setObject:[NSNumber numberWithInt:2] forKey:@"repeatEndType"];
                [params setObject:endrepeat forKey:@"repeatEndTime"];
            }
        }
    }
    
    [params setObject:@(1) forKey:@"privateFlag"];
    
    row = [self.form formRowWithTag:@"remind"];
    [params setObject:([row.value formValue] ? : @-1) forKey:@"remindType"];
    
    row = [self.form formRowWithTag:@"remark"];
    [params setObject:(row.value ? : @"") forKey:@"remark"];
    
    row = [self.form formRowWithTag:@"business"];
    if (row.value) {
        if ([[row.value allKeys] containsObject:@"businessType"]) {
            [params setObject:[row.value objectForKey:@"businessType"] forKey:@"businessType"]; //业务类型
        }
        if ([[row.value allKeys] containsObject:@"businessId"]) {
            [params setObject:[row.value objectForKey:@"businessId"] forKey:@"businessId"]; //业务id
        }
    }
    
    [self.view beginLoading];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_SCHEDULE_CREATE] params:params success:^(id responseObj) {
        [self.view endLoading];
        
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            [CommonFuntion showToast:@"创建日程成功" inView:self.view];
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self rightButtonItemPress];
            };
            [comRequest loginInBackground];
        }else{
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [CommonFuntion showToast:@"创建日程失败" inView:self.view];
        }
    } failure:^(NSError *error) {
        [self.view endLoading];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [CommonFuntion showToast:NET_ERROR inView:self.view];
    }];
}

- (void)didTouchButton:(XLFormRowDescriptor*)sender {
    [self.form removeFormSection:[[self.form formSections] lastObject]];
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    
    
    
    ExportAddress *address = [[ExportAddress alloc] init];
    [address.selectedArray  addObject:[self getDefaultAttentPeople]];
    
    // 参与人
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [tempArray addObject:[self getDefaultAttentPeople]];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"attend" rowType:XLFormRowDescriptorTypeSelectorPush title:@"参与人"];
    row.selectorTitle = @"编辑参与人";
    row.noValueDisplayText = @"点击选择";
    row.action.viewControllerClass = [EditAddressViewController class];
    row.value  = [ExportAddress initWithArray:tempArray];
    [section addFormRow:row];
    
    // 关联业务
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"business" rowType:XLFormRowDescriptorTypeSelectorTextDetail];
    __weak typeof(self) weak_self = self;
    row.value = @{@"text" : @"关联业务",
                     @"detail" : @"点击选择"};
    row.action.formBlock = ^(XLFormRowDescriptor *sender) {
        RelatedBusinessController *controller = [[RelatedBusinessController alloc] init];
        weak_self.RefreshBussineBlock = ^(NSDictionary *fromDic){
            XLFormRowDescriptor *rowDescriptor = [weak_self.form formRowWithTag:@"business"];
            rowDescriptor.value = @{@"text" : @"关联业务",
                                    @"detail" : [[fromDic objectForKey:@"dataSource"] objectForKey:@"name"],
                                    @"businessType" : [fromDic objectForKey:@"type"],
                                    @"businessId" : [NSString stringWithFormat:@"%@", [[fromDic objectForKey:@"dataSource"] safeObjectForKey:@"id"]]};
            [weak_self updateFormRow:rowDescriptor];
        };
        [self.navigationController pushViewController:controller animated:YES];
    };
    [section addFormRow:row];
#warning 产品需求先封掉重复的模块12月25号
    /*
    // 设置重复
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"repeat" rowType:XLFormRowDescriptorTypeSelectorPush title:@"设置重复"];
    row.selectorTitle = @"设置重复";
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"不重复"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"不重复"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"每天重复"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"每周重复"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"每月重复"]];
    [section addFormRow:row];
    */
     
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
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"remark" rowType:XLFormRowDescriptorTypeTextView];
//    [row.cellConfigAtConfigure setObject:@"备注" forKey:@"textView.placeholder"];
//    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"remark" rowType:XLFormRowDescriptorTypeCustomTextView];
    [row.cellConfigAtConfigure setObject:@"备注" forKey:@"titleLabel.text"];
    [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textView.placeholder"];
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
    
    if ([rowDescriptor.tag isEqualToString:@"title"]){
        ScheduleType *type = (ScheduleType *)rowDescriptor.value;
        NSString *name = type.name;
        if (name == nil || [[name stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        }else{
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }
        
    }else  if ([rowDescriptor.tag isEqualToString:@"allDay"]){
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
    }else if ([rowDescriptor.tag isEqualToString:@"repeat"]){
        
        XLFormSectionDescriptor *section;
        XLFormRowDescriptor *row;
        section = [self.form formSectionAtIndex:3];
        row = [self.form formRowWithTag:@"endRepeat"];
        
        if ([[rowDescriptor.value formValue] integerValue] == 1){
            if (row) {
                [section removeFormRow:row];
            }
        }else{
            if (!row) {
                
                row = [XLFormRowDescriptor formRowDescriptorWithTag:@"endRepeat" rowType:XLFormRowDescriptorTypeSelectorPush title:@"结束重复"];
                //                row.noValueDisplayText = @"永不结束";
                
                row.value = [XLFormOptionsObject formOptionsObjectWithValue:@"永不结束" displayText:@"永不结束"];
                row.action.viewControllerClass = [NewScheduleEndRepeatViewController class];
                [section addFormRow:row afterRow:[self.form formRowWithTag:@"repeat"]];
            }
        }
    }else if ([rowDescriptor.tag isEqualToString:@"endRepeat"]) {
        rowDescriptor.action.viewControllerClass = [NewScheduleEndRepeatViewController class];
    }else if ([rowDescriptor.tag isEqualToString:@"attend"]) {
        if ([rowDescriptor.value formValue]) {
            rowDescriptor.selectorTitle = @"编辑参与人";
            rowDescriptor.action.viewControllerClass = [EditAddressViewController class];
        }else {
            rowDescriptor.selectorTitle = @"选择参与人";
            rowDescriptor.action.viewControllerClass = [ExportAddressViewController class];
        }
    }else if ([rowDescriptor.tag isEqualToString:@"remind"]) {
        if ([rowDescriptor.value formValue]) {
            
        }else {
            rowDescriptor.value = [XLFormOptionsObject formOptionsObjectWithValue:@(-1) displayText:@"不提醒"];
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


#pragma  mark - button Action
-(void)leftButtonPress{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定放弃已填写内容" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 1001;
    [alertView show];
}


#pragma mark - delegate UIAlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1001) {
        // 退出
        if(buttonIndex == 0)
        {
        }
        else if(buttonIndex == 1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


@end
