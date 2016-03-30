//
//  WorkReportNewViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WRNewViewController.h"
#import <XLForm.h>
#import "AFNHttp.h"
#import "SBJson.h"
#import "WRNewItem.h"
#import "NSDate+Utils.h"
#import "WRWorkResultCell.h"
#import "AddressSelectedController.h"
#import "ExportAddressViewController.h"
#import "EditAddressViewController.h"
#import <MBProgressHUD.h>
#import <AFHTTPRequestOperationManager.h>
#import "CommonFuntion.h"
#import "AddressBook.h"
#import "ExportAddress.h"
#import "WorkSelectContectsViewController.h"
#import "XLFormCustomTextViewCell.h"
#import "XLFormCustomDateCell.h"
#import "DateAndTimeValueTrasformer.h"

static NSString *const kReportDate = @"date";
static NSString *const kActivityRecords = @"activityRecords";
static NSString *const kApproval = @"approval";
static NSString *const kCopys = @"copys";

@interface WRNewViewController ()

@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) NSMutableArray *oldCCUseridsArray;

// 从新建报告中获取数据源
- (void)getDataSourceFromNew;
// 从草稿中获取数据源
- (void)getDataSourceFromSavePaper;
// 创建表格
- (void)createXLFormWithSource:(NSDictionary*)sourceDict;
@end

@implementation WRNewViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(completeButtonPress)];
    rightButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    self.form = form;
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _oldCCUseridsArray = [[NSMutableArray alloc] initWithCapacity:0];

    if (_newType == WorkReportNewTypeNew) {
        [self getDataSourceFromNew];
    }else if (_newType == WorkReportNewTypeSavePaper) {
        [self getDataSourceFromSavePaper];
    }else if (_newType == WorkReportNewTypeEdit) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self createXLFormWithSource:_editDataSource];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)getDataSourceFromNew {
    
    NSArray *reportTypeArray = @[@"dayReport", @"weekReport", @"monthReport"];
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:reportTypeArray[_reportType] forKey:@"type"];
    
    // 发起请求
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",kNetPath_Oa_Server_Base,REPORT_CREATE] params:params success:^(id responseObj) {
        [hud hide:YES];
        //字典转模型
        NSLog(@"新建工作报告 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self createXLFormWithSource:responseObj];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"无法连接到网络，请检查你的网络配置";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)getDataSourceFromSavePaper {
    
    NSArray *reportTypeArray = @[@"dayReport", @"weekReport", @"monthReport"];
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSNumber numberWithInteger:_savePaperReportId] forKey:@"id"];
    [params setObject:reportTypeArray[_reportType] forKey:@"type"];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",kNetPath_Oa_Server_Base,REPORT_DETAILS] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"草稿详情 = %@", responseObj);
        
        if (![[responseObj objectForKey:@"status"] integerValue]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            _editDataSource = responseObj;
            [self createXLFormWithSource:_editDataSource];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"error:%@",error);
    }];
}

// 限制textField字数
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > MAX_LIMIT_TEXTFIELD) {
        textField.text = [textField.text substringToIndex:MAX_LIMIT_TEXTFIELD];
    }
}

- (void)createXLFormWithSource:(NSDictionary*)sourceDict {
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    /*
     case 0:
     string = [NSString transDateWithTimeInterval:[sourceDict objectForKey:@"createTime"] andCustomFormate:@"yyyy-MM-dd"];
     break;
     case 1:
     string = [NSString transDateToWeekWithTimeInterval:[sourceDict objectForKey:@"reportTime"]];
     break;
     case 2:
     //            string = [NSString transDateWithTimeInterval:[sourceDict objectForKey:@"reportTime"] andCustomFormate:@"yyyy年MM月"];
     string  = [CommonFuntion transDateWithTimeInterval:[[sourceDict safeObjectForKey:@"reportTime"] longLongValue] withFormat:@"yyyy年MM月"];
     break;
     */
    
    // 日期
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    
    if (_reportType == 0) { // 日报
        row = [XLFormRowDescriptor formRowDescriptorWithTag:kReportDate rowType:XLFormRowDescriptorTypeDateInline title:@"日期"];
        [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
        
        if (_newType == WorkReportNewTypeNew) {
            row.value = [NSDate new];
        }else{
            
//           [CommonFuntion stringToDate:[CommonFuntion transDateWithTimeInterval:[[sourceDict safeObjectForKey:@"createTime"] longLongValue] withFormat:@"yyyy-MM-dd"] Format:@"yyyy-MM-dd"];
            row.value = [CommonFuntion stringToDate:[CommonFuntion transDateWithTimeInterval:[[sourceDict safeObjectForKey:@"reportTime"] longLongValue] withFormat:@"yyyy-MM-dd"] Format:@"yyyy-MM-dd"];
        }
        
        
        row.disabled = (_newType == WorkReportNewTypeEdit ? @1 : @0);
        [section addFormRow:row];
    }else if (_reportType == 1) {   // 周报
        row = [XLFormRowDescriptor formRowDescriptorWithTag:kReportDate rowType:XLFormRowDescriptorTypeSelectorPush title:@"日期"];
        row.selectorTitle = @"日期";
        
        
        if (_newType == WorkReportNewTypeNew) {
            row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:[NSString transDateToWeekWithCurrentDate]];
        }else{
            
            row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:[NSString transDateToWeekWithTimeInterval:[sourceDict objectForKey:@"reportTime"]]];
        }
        
        row.disabled = (_newType == WorkReportNewTypeEdit ? @1 : @0);
        row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:[NSString transDateFromCurrentDateWithDayCount:-14]],
                                [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:[NSString transDateFromCurrentDateWithDayCount:-7]],
                                [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:[NSString transDateToWeekWithCurrentDate]],
                                [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:[NSString transDateFromCurrentDateWithDayCount:7]],
                                [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:[NSString transDateFromCurrentDateWithDayCount:14]]];
        [section addFormRow:row];
        
    }else { // 月报
        row = [XLFormRowDescriptor formRowDescriptorWithTag:kReportDate rowType:XLFormRowDescriptorTypeSelectorPush title:@"日期"];
        row.selectorTitle = @"日期";
        NSDate *currentDate = [NSDate new];
        
        
        if (_newType == WorkReportNewTypeNew) {
            row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:[NSString stringWithFormat:@"%d-%02d", currentDate.year, currentDate.month]];
        }else{
            row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:[CommonFuntion transDateWithTimeInterval:[[sourceDict safeObjectForKey:@"reportTime"] longLongValue] withFormat:@"yyyy-MM"]];
        }
        
        row.disabled = (_newType == WorkReportNewTypeEdit ? @1 : @0);

        NSMutableArray *selectorArray = [[NSMutableArray alloc] initWithCapacity:5];
        NSInteger year, month;
        for (int i = 0; i < 5; i ++) {
            if (i < 2) {
                year = currentDate.year;
                month = currentDate.month - 2 + i;
            }else if (i > 2) {
                year = currentDate.year;
                month = currentDate.month + i - 2;
            }else{
                year = currentDate.year;
                month = currentDate.month;
            }
            
            if (month == 0) {
                year -= 1;
                month = 12;
            }else if (month == -1) {
                year -= 1;
                month = 11;
            }else if (month == 13) {
                year += 1;
                month = 1;
            }else if (month == 14) {
                year += 1;
                month = 2;
            }
            
            [selectorArray addObject:[XLFormOptionsObject formOptionsObjectWithValue:@(i) displayText:[NSString stringWithFormat:@"%d-%02d", year, month]]];
        }
        row.selectorOptions = selectorArray;
        [section addFormRow:row];
    }
    
    // 工作自动汇总
    if (![[sourceDict objectForKey:@"statics"] integerValue]) {
        NSArray *array = @[@"当日工作自动汇总", @"本周工作自动汇总", @"本月工作自动汇总"];
        section = [XLFormSectionDescriptor formSectionWithTitle:array[_reportType]];
        [self.form addFormSection:section];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:kActivityRecords rowType:XLFormRowDescriptorTypeWorkReportActivityRecords];
        row.value = @(_reportType);
        [section addFormRow:row];
    }
    
    // 组建表格数据
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    for (NSDictionary *tempDict in (_newType == WorkReportNewTypeNew ? [sourceDict valueForKeyPath:@"columns"] : [sourceDict valueForKeyPath:@"columnList"])) {
        WRNewItem *item = [WRNewItem initWithDictionary:tempDict];
        [_sourceArray addObject:item];
        
        switch (item.m_columnType) {
            case 1: {   // 文本
                row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeText title:item.m_name];
                //                [row.cellConfig setObject:[UIFont systemFontOfSize:14] forKey:@"textField.font"];
                [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                if (item.m_required) {
                    [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textField.placeholder"];
                }else {
                    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
                }
                if ([item.m_result length]) {
                    row.value = item.m_result;
                }
                [section addFormRow:row];
            }
                break;
            case 2: {   // 文本域
//                row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeTextView];
//                //                [row.cellConfig setObject:[UIFont systemFontOfSize:14] forKey:@"textView.font"];
//                if (item.m_required) {
//                    [row.cellConfigAtConfigure setObject:item.m_name forKey:@"textView.placeholder"];
//                }else {
//                    [row.cellConfigAtConfigure setObject:[NSString stringWithFormat:@"%@(必填)", item.m_name] forKey:@"textView.placeholder"];
//                }
//                if ([item.m_result length]) {
//                    row.value = item.m_result;
//                }
//                [section addFormRow:row];
                
                row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeCustomTextView];
                [row.cellConfigAtConfigure setObject:item.m_name forKey:@"titleLabel.text"];
                if (item.m_required) {
                    [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textView.placeholder"];
                }
                else {
                    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textView.placeholder"];
                }
                if ([item.m_result length]) {
                    row.value = item.m_result;
                }
                [section addFormRow:row];
            }
                break;
            case 3: {   // 单选框
                row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeSelectorPush title:item.m_name];
                row.selectorTitle = item.m_name;
                if (item.m_required) {
                    row.noValueDisplayText = @"点击填写";
                }else {
                    row.noValueDisplayText = @"必填";
                }
                NSMutableArray *selectArray = [NSMutableArray arrayWithCapacity:item.m_selectArray.count];
                for (NSDictionary *tempDict in item.m_selectArray) {
                    XLFormOptionsObject *optionsObject = [XLFormOptionsObject formOptionsObjectWithValue:tempDict[@"id"] displayText:tempDict[@"value"]];
                    [selectArray addObject:optionsObject];
                }
                row.selectorOptions = selectArray;
                if ([item.m_result length]) {
                    for (XLFormOptionsObject *optionObj in selectArray) {
                        if ([item.m_result integerValue] == [optionObj.formValue integerValue]) {
                            row.value = optionObj;
                        }
                    }
                }
                [section addFormRow:row];
            }
                break;
            case 4: {   // 多选框
                row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeMultipleSelector title:item.m_name];
                row.selectorTitle = item.m_name;
                if (item.m_required) {
                    row.noValueDisplayText = @"点击填写";
                }else {
                    row.noValueDisplayText = @"必填";
                }
                NSMutableArray *selectArray = [NSMutableArray arrayWithCapacity:item.m_selectArray.count];
                NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:0];
                for (NSDictionary *tempDict in item.m_selectArray) {
                    XLFormOptionsObject *optionsObject = [XLFormOptionsObject formOptionsObjectWithValue:tempDict[@"id"] displayText:tempDict[@"value"]];
                    [selectArray addObject:optionsObject];
                }
                row.selectorOptions = selectArray;
                if ([item.m_result length]) {
                    NSArray *array = [item.m_result componentsSeparatedByString:@","];
                    for (NSString *valueStr in array) {
                        for (XLFormOptionsObject *optionObj in selectArray) {
                            if ([valueStr integerValue] == [optionObj.formValue integerValue]) {
                                [valueArray addObject:optionObj];
                            }
                        }
                    }
                    row.value = valueArray;
                }
                [section addFormRow:row];
            }
                break;
            case 5: {   // 整数
                row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeInteger title:item.m_name];
                [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                if (item.m_required) {
                    [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textField.placeholder"];
                }else {
                    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
                }
                if ([item.m_result length]) {
                    row.value = item.m_result;
                }
                [section addFormRow:row];
            }
                break;
            case 6: {   // 浮点数
                row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeDecimal title:item.m_name];
                [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                if (item.m_required) {
                    [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textField.placeholder"];
                }else {
                    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
                }
                if ([item.m_result length]) {
                    row.value = item.m_result;
                }
                [section addFormRow:row];
            }
                break;
            case 7: {  // 日期
                row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeCustomDate title:item.m_name];
                
                if (!item.m_fullDate) {
                    [row.cellConfigAtConfigure setObject:@(XLFormCustomDateDatePickerModeDateTime) forKey:@"formDatePickerMode"];
                     row.valueTransformer = [DateTimeValueTrasformer class];
                }else{
                    [row.cellConfigAtConfigure setObject:@(XLFormCustomDateDatePickerModeDate) forKey:@"formDatePickerMode"];
                }
               
                
                [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
                if (item.m_required) {
                    row.noValueDisplayText = @"点击填写";
                }else {
                    row.noValueDisplayText = @"必填";
                    if (![CommonFuntion checkNullForValue:item.m_result]) {
                        row.value = [NSDate date];
                    }
                }
                
                if ([CommonFuntion checkNullForValue:item.m_result]) {
                    NSNumber *timeSince1970 = (NSNumber *)item.m_result;
                    NSTimeInterval timeSince1970TimeInterval = timeSince1970.doubleValue/1000;
                    row.value = [NSDate dateWithTimeIntervalSince1970:timeSince1970TimeInterval];
                }
                [section addFormRow:row];
            }
                default:
                break;
        }
    }
    
    // 批阅人
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kApproval rowType:XLFormRowDescriptorTypeSelectorPush title:@"批阅人"];
    ExportAddress *address = [[ExportAddress alloc] init];
    if (_newType == WorkReportNewTypeEdit || _newType == WorkReportNewTypeSavePaper) {
        if ([CommonFuntion checkNullForValue:[sourceDict objectForKey:@"reviewUsers"]]) {
            NSArray *userArray = [NSArray arrayWithObject:[sourceDict objectForKey:@"reviewUsers"]];
            [address.selectedArray addObjectsFromArray:[self getDefaultAttentPeople:userArray]];
        }
    } else {
        if ([CommonFuntion checkNullForValue:[sourceDict objectForKey:@"reveiwer"]]) {
            NSArray *userArray = [NSArray arrayWithObject:[sourceDict objectForKey:@"reveiwer"]];
            [address.selectedArray addObjectsFromArray:[self getDefaultAttentPeople:userArray]];
        }
    }
    if (address.selectedArray && address.selectedArray.count > 0) {
        row.value = address;
    } else {
        row.noValueDisplayText = @"点击选择";
    }
    row.selectorTitle = @"选择批阅人";
    row.action.viewControllerClass = [AddressSelectedController class];
    row.disabled = (_newType == WorkReportNewTypeEdit ? @1 : @0);
    [section addFormRow:row];
    
    // 抄送人
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *tempDict in sourceDict[@"ccUsers"]) {
        AddressBook *item = [NSObject objectOfClass:@"AddressBook" fromJSON:tempDict];
        [tempArray addObject:item];
        [_oldCCUseridsArray addObject:[NSString stringWithFormat:@"%@", item.id]];
    }
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCopys rowType:XLFormRowDescriptorTypeSelectorPush title:@"抄送人"];
    row.noValueDisplayText = @"点击选择";
    if (tempArray.count) {
        row.selectorTitle = @"编辑抄送人";
        row.action.viewControllerClass = [EditAddressViewController class];
    }else {
        row.selectorTitle = @"选择抄送人";
        row.action.viewControllerClass = [WorkSelectContectsViewController class];
    }
    if (tempArray.count) {
        row.value = [ExportAddress initWithArray:tempArray];
    }
    row.disabled = (_newType == WorkReportNewTypeEdit ? @1 : @0);
    [section addFormRow:row];
}

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    
    NSIndexPath *indexPath = [self.form indexPathOfFormRow:rowDescriptor];
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[XLFormTextFieldCell class]]) {
        XLFormTextFieldCell *textFieldCell = cell;
        [textFieldCell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
    if ([rowDescriptor.tag isEqualToString:kCopys]) {
        if ([rowDescriptor.value formValue]) {
            rowDescriptor.selectorTitle = @"编辑抄送人";
            rowDescriptor.action.viewControllerClass = [EditAddressViewController class];
        }else {
            rowDescriptor.selectorTitle = @"选择抄送人";
            rowDescriptor.action.viewControllerClass = [WorkSelectContectsViewController class];
        }
    }else if ([rowDescriptor.tag isEqualToString:kReportDate]) {
        
        if (_reportType == 1) {   // 周报
            if (![rowDescriptor.value formValue]) {
                rowDescriptor.value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:[NSString transDateToWeekWithCurrentDate]];
            }
            
        }else if (_reportType == 2){///月报
            if (![rowDescriptor.value formValue]) {
                NSDate *currentDate = [NSDate new];
                rowDescriptor.value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:[NSString stringWithFormat:@"%d-%02d", currentDate.year, currentDate.month]];
            }
            
        }
    }
    else if ([rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeCustomDate] && [oldValue isEqual:[NSNull null]]) {
        [self updateFormRow:rowDescriptor];
    }
    
    for (WRNewItem *item in _sourceArray) {
        if ([item.m_name isEqualToString:rowDescriptor.tag]) {
            
            switch (item.m_columnType) {
                case 3: {// 单选
                    XLFormOptionsObject *oldOption = oldValue;
                    XLFormOptionsObject *newOption = newValue;
                    if (![newOption isEqual:[NSNull null]]) {
                        item.m_result = [newOption formValue];
                    }
                    else {
                        if (!item.m_required) {
                            rowDescriptor.value = oldOption;
                        }
                        else {
                            item.m_result = nil;
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - event response
- (void)cancelButtonPress {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (_newType == WorkReportNewTypeEdit) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存草稿", @"不保存", nil];
    [actionSheet showInView:self.view];
}

- (void)completeButtonPress {
    // 参数：type(报告类型dayReport,weekReport,monthReport),id（报告id，新增时为空，编辑时非空）,customId（扩展id,报告详细所返回，新增时为空，编辑时非空）,reportTime(报告时间，日报和月报 yyyy-MM-dd),startTime(开始时间 周报 yyyy-MM-dd),endTime（结束时间 周报 yyyy-MM-dd）,reviewerId（批阅人id）,ccUserIds （抄送人id，多个抄送人以逗号进行分隔）,json （动态字段组成的json串）(propertyName（对应后台属性，报告详细所返回）,object（此属性对应的实体类名,报告详细所返回）,result（属性值） 3个属性组成的集合)
    
//    if (!_editDataSource)
//        return;
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    XLFormRowDescriptor *row;
    
    
    ///必填条件判断
    
    
    
    NSArray *reportTypeArray = @[@"dayReport", @"weekReport", @"monthReport"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:reportTypeArray[_reportType] forKey:@"type"];
    if (_newType == WorkReportNewTypeNew) {
        [params setObject:@"" forKey:@"id"];
        [params setObject:@"" forKey:@"customId"];
    }else {
        [params setObject:_editDataSource[@"id"] forKey:@"id"];
        [params setObject:_editDataSource[@"customId"] forKey:@"customId"];
    }
    
    // 获取时间
    row = [self.form formRowWithTag:kReportDate];
    if (_reportType == 0) {
        [params setObject:[row.value stringYearMonthDayForLine] forKey:@"reportTime"];
    }else if (_reportType == 1) {
        XLFormOptionsObject *optionsObject = row.value;
        NSArray *stringArray = [[optionsObject formDisplayText] componentsSeparatedByString:@"~"];
        [params setObject:stringArray[0] forKey:@"startTime"];
        [params setObject:stringArray[1] forKey:@"endTime"];
    }else if (_reportType == 2) {
        NSDate *currentDate = [NSDate new];
        XLFormOptionsObject *optionsObject = row.value;
        [params setObject:[NSString stringWithFormat:@"%@-%02d", [optionsObject formDisplayText], currentDate.day] forKey:@"reportTime"];
    }
    NSMutableArray *newIdsArray = [NSMutableArray arrayWithCapacity:0];
    if (_newType == WorkReportNewTypeNew) {
        // 获取批阅人
        row = [self.form formRowWithTag:kApproval];
        if ([[row.value formValue] integerValue] == [appDelegateAccessor.moudle.userId integerValue]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"不能把自己设为批阅人" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        // 获取批阅人
//        row = [self.form formRowWithTag:kApproval];
        NSString *reviewerId = @"";
        if (row.value && [row.value formValue]) {
            reviewerId = [row.value formValue];
        }
        [params setObject:reviewerId forKey:@"reviewerId"];
        
        // 获取抄送人
        row = [self.form formRowWithTag:kCopys];
        // 先将抄送人中有批阅人给过滤掉
        NSString *copysString = @"";
        if (row.value && [row.value formValue]) {
            NSArray *copysArray = [[row.value formValue] componentsSeparatedByString:@","];
            for (int i = 0; i < copysArray.count; i ++) {
                NSString *copyIdStr = copysArray[i];
                if ([copyIdStr longLongValue] == [reviewerId longLongValue])
                    continue;
                if (i == 0) {
                    copysString = [NSString stringWithFormat:@"%@", copyIdStr];
                }else {
                    copysString = [NSString stringWithFormat:@"%@,%@", copysString, copyIdStr];
                }
                if (![_oldCCUseridsArray containsObject:copyIdStr]) {
                    [newIdsArray addObject:copyIdStr];
                }
            }
        }
        [params setObject:copysString forKey:@"ccUserIds"];
        
    }else {
//        // 批阅人
//        [params setObject:_editDataSource[@"reviewUsers"][@"id"] forKey:@"reviewerId"];
//        // 抄送人
//        NSString *copyUserId = @"";
//        for (int i = 0; i < [[_editDataSource objectForKey:@"ccUsers"] count]; i ++) {
//            NSDictionary *tempDict = [[_editDataSource objectForKey:@"ccUsers"] objectAtIndex:i];
//            if (i == 0) {
//                copyUserId = [NSString stringWithFormat:@"%@", [tempDict objectForKey:@"id"]];
//            }else {
//                copyUserId = [NSString stringWithFormat:@"%@,%@", copyUserId, [tempDict objectForKey:@"id"]];
//            }
//        }
//        [params setObject:copyUserId forKey:@"ccUserIds"];
        // 获取批阅人
        row = [self.form formRowWithTag:kApproval];
        if ([[row.value formValue] integerValue] == [appDelegateAccessor.moudle.userId integerValue]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"不能把自己设为批阅人" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        // 获取批阅人
        //        row = [self.form formRowWithTag:kApproval];
        NSString *reviewerId = @"";
        if (row.value && [row.value formValue]) {
            reviewerId = [row.value formValue];
        }
        [params setObject:reviewerId forKey:@"reviewerId"];
        
        // 获取抄送人
        row = [self.form formRowWithTag:kCopys];
        // 先将抄送人中有批阅人给过滤掉
        NSString *copysString = @"";
        if (row.value && [row.value formValue]) {
            NSArray *copysArray = [[row.value formValue] componentsSeparatedByString:@","];
            for (int i = 0; i < copysArray.count; i ++) {
                NSString *copyIdStr = copysArray[i];
                if ([copyIdStr longLongValue] == [reviewerId longLongValue])
                    continue;
                if (i == 0) {
                    copysString = [NSString stringWithFormat:@"%@", copyIdStr];
                }else {
                    copysString = [NSString stringWithFormat:@"%@,%@", copysString, copyIdStr];
                }
                if (![_oldCCUseridsArray containsObject:copyIdStr]) {
                    [newIdsArray addObject:copyIdStr];
                }
            }
        }
        [params setObject:copysString forKey:@"ccUserIds"];
    }
    
    // 获取json串
    NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (WRNewItem *item in _sourceArray) {
        NSLog(@"----------------->");
        row = [self.form formRowWithTag:item.m_name];
        if (row.value) {
            if (item.m_columnType == 3) {   // 单选
                XLFormOptionsObject *optionsObject = row.value;
                if (item.m_required) {
                    [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                           @"object" : item.m_object,
                                           @"result" : (optionsObject ? optionsObject.formValue : @""),
                                           @"columnType" : [NSNumber numberWithInteger:item.m_columnType]}];
                }else {
                    if (optionsObject) {
                        [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                               @"object" : item.m_object,
                                               @"result" : optionsObject.formValue,
                                               @"columnType" : [NSNumber numberWithInteger:item.m_columnType]}];
                    }else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@不能为空", item.m_name] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        [alertView show];
                        return;
                    }
                }
            }else if (item.m_columnType == 4) {     // 多选
                NSString *objectString = @"";
                for (int i = 0; i < [row.value count]; i ++) {
                    XLFormOptionsObject *optionsObject = row.value[i];
                    if (i == 0) {
                        objectString = [NSString stringWithFormat:@"%@", optionsObject.formValue];
                    }else {
                        objectString = [NSString stringWithFormat:@"%@,%@", objectString, optionsObject.formValue];
                    }
                }
                if (!item.m_required) {
                    if (![objectString length]) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@不能为空", item.m_name] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        [alertView show];
                        return;
                    }
                }
                [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                       @"object" : item.m_object,
                                       @"result" : objectString,
                                       @"columnType" : [NSNumber numberWithInteger:item.m_columnType]}];
            }else if (item.m_columnType == 7) {     // 日期
                NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                if (!item.m_fullDate) {
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                }else{
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                }
                NSString *string = [dateFormatter stringFromDate:row.value];
                if (!item.m_required) {
                    if (!string) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@不能为空", item.m_name] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        [alertView show];
                        return;
                    }
                }
                [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                       @"object" : item.m_object,
                                       @"result" : (string ? string : @""),
                                       @"columnType" : [NSNumber numberWithInteger:item.m_columnType]}];
            }else {     // 其它

                if (!item.m_required) {
                    
                    NSLog(@"row m_required.value:%@",row.value);
                    
                    if (!row.value) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@不能为空", item.m_name] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        [alertView show];
                        return;
                    }
                }
                
                
                [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                       @"object" : item.m_object,
                                       @"result" : (row.value ? row.value : @""),
                                       @"columnType" : [NSNumber numberWithInteger:item.m_columnType]}];
            }
        }else{
            if (!item.m_required) {
                
                NSLog(@"row m_required.value:%@",row.value);
                
                if (!row.value) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@不能为空", item.m_name] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                    return;
                }
            }else{
                if (item.m_columnType == 3) {
                    NSLog(@"item.m_propertyName:%@",item.m_propertyName);
                }
                [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                       @"object" : item.m_object,
                                       @"result" : (row.value ? row.value : @""),
                                       @"columnType" : [NSNumber numberWithInteger:item.m_columnType]}];
                
            }
//            if ([row.tag isEqualToString:@"明日计划"]) {
//                [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
//                                       @"object" : item.m_object,
//                                       @"result" : (row.value ? row.value : @"")}];
//            }
            
            
        }
        
    }
    
    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc] init];
    NSString *jsonString = [jsonParser stringWithObject:jsonArray];
    [params setObject:jsonString forKey:@"json"];
    
    NSLog(@"2params = %@", params);

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript",@"text/plain", nil];
    manager.requestSerializer.timeoutInterval = 15;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@%@",kNetPath_Oa_Server_Base, kNetPath_Report_Submit] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        ///图片
        
    } success:^(AFHTTPRequestOperation *operation,id responseObject) {
        [hud hide:YES];
        NSLog(@"responseObj:%@",responseObject);
        NSLog(@"desc:%@",[responseObject objectForKey:@"desc"]);
        if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == 0) {
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self getNewAddress:newIdsArray];
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
        }else{
            self.navigationItem.rightBarButtonItem.enabled = YES;
            NSString *desc = @"";
            desc = [responseObject objectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"提交失败";
            }
            kShowHUD(desc,nil)
        }
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        NSLog(@"error:%@",error);
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [hud hide:YES];
        kShowHUD(NET_ERROR)
        NSLog ( @"operation: %@" , operation. responseString );
        NSLog(@"error:%@",error);
    }];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    if (buttonIndex == 0) { // 保存草稿
        
        XLFormRowDescriptor *row;
        
        NSArray *reportTypeArray = @[@"dayReport", @"weekReport", @"monthReport"];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:COMMON_PARAMS];
        [params setObject:reportTypeArray[_reportType] forKey:@"type"];
        if (_newType == WorkReportNewTypeSavePaper) {
            [params setObject:_editDataSource[@"id"] forKey:@"id"];
            [params setObject:_editDataSource[@"customId"] forKey:@"customId"];
        }
        
        // 获取时间
        row = [self.form formRowWithTag:kReportDate];
        if (_reportType == 0) {
            [params setObject:[row.value stringYearMonthDayForLine] forKey:@"reportTime"];
        }else if (_reportType == 1) {
            XLFormOptionsObject *optionsObject = row.value;
            NSArray *stringArray = [[optionsObject formDisplayText] componentsSeparatedByString:@"~"];
            [params setObject:stringArray[0] forKey:@"startTime"];
            [params setObject:stringArray[1] forKey:@"endTime"];
        }else if (_reportType == 2) {
            NSDate *currentDate = [NSDate new];
            XLFormOptionsObject *optionsObject = row.value;
            [params setObject:[NSString stringWithFormat:@"%@-%02d", [optionsObject formDisplayText], currentDate.day] forKey:@"reportTime"];
        }
        
        
        // 获取批阅人
        row = [self.form formRowWithTag:kApproval];
        // 获取批阅人
        //        row = [self.form formRowWithTag:kApproval];
        NSString *reviewerId = @"";
        if (row.value && [row.value formValue]) {
            reviewerId = [row.value formValue];
        }
        [params setObject:reviewerId forKey:@"reviewerId"];
        
        // 获取抄送人
        row = [self.form formRowWithTag:kCopys];
        // 先将抄送人中有批阅人给过滤掉
        NSString *copysString = @"";
        if (row.value && [row.value formValue]) {
            NSArray *copysArray = [[row.value formValue] componentsSeparatedByString:@","];
            for (int i = 0; i < copysArray.count; i ++) {
                NSString *copyIdStr = copysArray[i];
                if ([copyIdStr longLongValue] == [reviewerId longLongValue])
                    continue;
                if (i == 0) {
                    copysString = [NSString stringWithFormat:@"%@", copyIdStr];
                }else {
                    copysString = [NSString stringWithFormat:@"%@,%@", copysString, copyIdStr];
                }
            }
        }
        [params setObject:copysString forKey:@"ccUserIds"];
        
        
        // 获取json串
        NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (WRNewItem *item in _sourceArray) {
            row = [self.form formRowWithTag:item.m_name];
            if (row.value) {
                if (item.m_columnType == 3) {   // 单选
                    XLFormOptionsObject *optionsObject = row.value;
                    if (item.m_required) {
                        [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                               @"object" : item.m_object,
                                               @"result" : (optionsObject ? optionsObject.formValue : @"")}];
                    }else {
                        if (optionsObject) {
                            [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                                   @"object" : item.m_object,
                                                   @"result" : optionsObject.formValue}];
                        }
                    }
                }else if (item.m_columnType == 4) {     // 多选
                    NSString *objectString = @"";
                    for (int i = 0; i < [row.value count]; i ++) {
                        XLFormOptionsObject *optionsObject = row.value[i];
                        if (i == 0) {
                            objectString = [NSString stringWithFormat:@"%@", optionsObject.formValue];
                        }else {
                            objectString = [NSString stringWithFormat:@"%@,%@", objectString, optionsObject.formValue];
                        }
                    }
                    
                    [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                           @"object" : item.m_object,
                                           @"result" : objectString}];
                }else if (item.m_columnType == 7) {     // 日期
                    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSString *string = [dateFormatter stringFromDate:row.value];
                    
                    [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                           @"object" : item.m_object,
                                           @"result" : (string ? string : @"")}];
                }else {     // 其它
                    [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                           @"object" : item.m_object,
                                           @"result" : (row.value ? row.value : @"")}];
                }
            }else{
                [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                       @"object" : item.m_object,
                                       @"result" : (row.value ? row.value : @"")}];
            }
        }
        
        
        MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc] init];
        NSString *jsonString = [jsonParser stringWithObject:jsonArray];
        [params setObject:jsonString forKey:@"json"];
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript",@"text/plain", nil];
        manager.requestSerializer.timeoutInterval = 15;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [manager POST:[NSString stringWithFormat:@"%@%@",kNetPath_Oa_Server_Base, kNetPath_Report_SavePaper] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            ///图片
            
        } success:^(AFHTTPRequestOperation *operation,id responseObject) {
            [hud hide:YES];
            NSLog(@"responseObj:%@",responseObject);
            NSLog(@"desc:%@",[responseObject objectForKey:@"desc"]);
            if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == 0) {
                if (self.refreshBlock) {
                    self.refreshBlock();
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                NSString *desc = @"";
                desc = [responseObject objectForKey:@"desc"];
                if ([desc isEqualToString:@""]) {
                    desc = @"提交失败";
                }
                kShowHUD(desc,nil)
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error:%@",error);
            [hud hide:YES];
            kShowHUD(NET_ERROR)
            NSLog ( @"operation: %@" , operation. responseString );
            NSLog(@"error:%@",error);
        }];
        
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    
//}

///初始化默认批阅人和抄送人
-(NSMutableArray *)getDefaultAttentPeople:(NSArray *)array {
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dict in array) {
        AddressBook *user = [[AddressBook alloc] init];
        user.id = [dict objectForKey:@"id"];
        user.name = [dict objectForKey:@"name"];
        user.icon = [dict objectForKey:@"icon"];
        [newArray addObject:user];
        NSLog(@"----%@", user.name);
    }
    return newArray;
}
- (void)getNewAddress:(NSArray *)idsArray {
    if (idsArray.count == 0) {
        return;
    }
    NSArray *allContactArray = [[FMDBManagement sharedFMDBManager] getAddressBookDataSource];
    NSMutableArray *newCacheArray = [NSMutableArray arrayWithArray:[[FMDBManagement sharedFMDBManager] getLastContactsAddressBookDataSource]];
    [[FMDBManagement sharedFMDBManager] deleteLastContactsAddressBookList];
    [[FMDBManagement sharedFMDBManager] creatLastContactsAddressBookTable];
    for (AddressBook *addModel in allContactArray) {
        if ([idsArray containsObject:[NSString stringWithFormat:@"%@", addModel.id]]) {
            [newCacheArray addObject:addModel];
        }
    }
    NSArray *newLastContactArray = [NSArray array];
    if (newCacheArray.count > 5) {
      newLastContactArray = [newCacheArray subarrayWithRange:NSMakeRange(newCacheArray.count - 5, 5)];
    } else {
        newLastContactArray = newCacheArray;
    }
    for (AddressBook *addModel in newLastContactArray) {
        
        [[FMDBManagement sharedFMDBManager] insertLastContactsAddressBookWithItem:addModel];
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
