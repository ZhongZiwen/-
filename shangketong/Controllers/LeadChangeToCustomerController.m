//
//  LeadChangeToCustomerController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LeadChangeToCustomerController.h"
#import "Helper.h"
#import <XLForm.h>
#import <SBJson4Writer.h>
#import "ColumnModel.h"
#import "ColumnSelectModel.h"
#import "LeadViewController.h"
#import "LeadListViewController.h"
#import "XLFormCustomDateCell.h"

@interface LeadChangeToCustomerController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSMutableArray *customerArray;
@property (strong, nonatomic) NSMutableArray *saleChanceArray;
@property (assign, nonatomic) BOOL isExpend;
@end

@implementation LeadChangeToCustomerController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(backButtonItemPress)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"转换" target:self action:@selector(rightButtonItemPress)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:_id forKey:@"id"];
    
    [self.view beginLoading];
    [self sendRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Lead_ChangeToCustomerInit_WithParams:_params block:^(id data, NSError *error) {
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempCustomeArray = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray *tempSaleChanceArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"customerColumns"]) {
                ColumnModel *item = [NSObject objectOfClass:@"ColumnModel" fromJSON:tempDict];
                for (NSDictionary *selectedDict in tempDict[@"select"]) {
                    ColumnSelectModel *selectItem = [NSObject objectOfClass:@"ColumnSelectModel" fromJSON:selectedDict];
                    [item.selectArray addObject:selectItem];
                }
                [item configResultWithDictionary:tempDict];
                [tempCustomeArray addObject:item];
            }
            for (NSDictionary *tempDict in data[@"saleChanceColumns"]) {
                ColumnModel *item = [NSObject objectOfClass:@"ColumnModel" fromJSON:tempDict];
                for (NSDictionary *selectedDict in tempDict[@"select"]) {
                    ColumnSelectModel *selectItem = [NSObject objectOfClass:@"ColumnSelectModel" fromJSON:selectedDict];
                    [item.selectArray addObject:selectItem];
                }
                [item configResultWithDictionary:tempDict];
                [tempSaleChanceArray addObject:item];
            }
            _customerArray = tempCustomeArray;
            _saleChanceArray = tempSaleChanceArray;
            [self reloadXLForm];
            
            if (![data[@"customerExist"] integerValue]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"客户已存在，系统将自动关联" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
            }
            
        }else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [self sendRequest];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
    }];
}

- (void)reloadXLForm {
    
    self.form = [XLFormDescriptor formDescriptor];
    
    [self configXLFormWithArray:_customerArray];
    
    /**
     * 添加更多信息
     */
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, kScreen_Width, 44);
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:@"＋同时创建销售机会" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addMoreButtonPress) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = button;
}

- (void)configXLFormWithArray:(NSArray*)array {
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    for (ColumnModel *columnItem in array) {
        
        switch ([columnItem.columnType integerValue]) {
            case 1: {   // 文本
                row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%@_%@", columnItem.object, columnItem.propertyName] rowType:XLFormRowDescriptorTypeText title:columnItem.name];
                [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                if ([columnItem.required integerValue]) {
                    [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textField.placeholder"];
                }else {
                    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
                }
                row.hidden = columnItem.showWhenInit;
                if (columnItem.stringResult) {
                    row.value = columnItem.stringResult;
                }
                row.disabled = columnItem.editAble;
                [section addFormRow:row];
            }
                break;
            case 2: {   // 文本域
                row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%@_%@", columnItem.object, columnItem.propertyName] rowType:XLFormRowDescriptorTypeTextView];
                if ([columnItem.required integerValue]) {
                    [row.cellConfigAtConfigure setObject:columnItem.name forKey:@"textView.placeholder"];
                }else {
                    [row.cellConfigAtConfigure setObject:[NSString stringWithFormat:@"%@(必填)", columnItem.name] forKey:@"textView.placeholder"];
                }
                row.hidden = columnItem.showWhenInit;
                if (columnItem.stringResult) {
                    row.value = columnItem.stringResult;
                }
                row.disabled = columnItem.editAble;
                [section addFormRow:row];
            }
                break;
            case 3: {   // 单选框
                row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%@_%@", columnItem.object, columnItem.propertyName] rowType:XLFormRowDescriptorTypeSelectorPush title:columnItem.name];
                row.selectorTitle = columnItem.name;    // 进去单选界面的title
                if ([columnItem.required integerValue]) {
                    row.noValueDisplayText = @"点击填写";
                }else {
                    row.noValueDisplayText = @"必填";
                }
                NSMutableArray *optionsArray = [[NSMutableArray alloc] initWithCapacity:columnItem.selectArray.count];
                for (ColumnSelectModel *tempSelect in columnItem.selectArray) {
                    XLFormOptionsObject *object = [XLFormOptionsObject formOptionsObjectWithValue:tempSelect.id displayText:tempSelect.value];
                    [optionsArray addObject:object];
                    
                    if ([columnItem.stringResult isEqualToString:tempSelect.id]) {
                        row.value = object;
                    }
                }
                row.selectorOptions = optionsArray;
                row.hidden = columnItem.showWhenInit;
                row.disabled = columnItem.editAble;
                [section addFormRow:row];
            }
                break;
            case 4: {   // 多选框
                row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%@_%@", columnItem.object, columnItem.propertyName] rowType:XLFormRowDescriptorTypeMultipleSelector title:columnItem.name];
                row.selectorTitle = columnItem.name;    // 进入多选界面的title
                if ([columnItem.required integerValue]) {
                    row.noValueDisplayText = @"点击填写";
                }else {
                    row.noValueDisplayText = @"必填";
                }
                NSMutableArray *optionsArray = [[NSMutableArray alloc] initWithCapacity:columnItem.selectArray.count];
                NSMutableArray *valuesArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (ColumnSelectModel *tempSelect in columnItem.selectArray) {
                    XLFormOptionsObject *object = [XLFormOptionsObject formOptionsObjectWithValue:tempSelect.id displayText:tempSelect.value];
                    [optionsArray addObject:object];
                    
                    for (NSString *valueStr in columnItem.arrayResult) {
                        if ([valueStr isEqualToString:tempSelect.id]) {
                            [valuesArray addObject:object];
                            break;
                        }
                    }
                }
                row.selectorOptions = optionsArray;
                if (valuesArray.count) {
                    row.value = valuesArray;
                }
                row.hidden = columnItem.showWhenInit;
                row.disabled = columnItem.editAble;
                [section addFormRow:row];
            }
                break;
            case 5: {   // 整数
                row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%@_%@", columnItem.object, columnItem.propertyName] rowType:XLFormRowDescriptorTypeInteger title:columnItem.name];
                [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                if ([columnItem.required integerValue]) {
                    [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textField.placeholder"];
                }else {
                    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
                }
                row.hidden = columnItem.showWhenInit;
                if (columnItem.stringResult) {
                    row.value = @([columnItem.stringResult integerValue]);
                }
                row.disabled = columnItem.editAble;
                [section addFormRow:row];
            }
                break;
            case 6: {   // 浮点数
                row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%@_%@", columnItem.object, columnItem.propertyName] rowType:XLFormRowDescriptorTypeDecimal title:columnItem.name];
                [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                if ([columnItem.required integerValue]) {
                    [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textField.placeholder"];
                }else {
                    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
                }
                row.hidden = columnItem.showWhenInit;
                if (columnItem.stringResult) {
                    row.value = @([columnItem.stringResult integerValue]);
                }
                row.disabled = columnItem.editAble;
                [section addFormRow:row];
            }
                break;
            case 7: {   // 日期
                row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%@_%@", columnItem.object, columnItem.propertyName] rowType:XLFormRowDescriptorTypeCustomDate title:columnItem.name];
                [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
                if ([columnItem.required integerValue]) {
                    row.noValueDisplayText = @"点击填写";
                }else {
                    row.noValueDisplayText = @"必填";
                }
                row.hidden = columnItem.showWhenInit;
                if (columnItem.dateResult) {
                    row.value = columnItem.dateResult;
                }
                [section addFormRow:row];
            }
                break;
            case 8: {   // 创建section
                section = [XLFormSectionDescriptor formSectionWithTitle:columnItem.name];
                [self.form addFormSection:section];
            }
                break;
            case 100: { // 所属部门
                row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%@_%@", columnItem.object, columnItem.propertyName] rowType:XLFormRowDescriptorTypeSelectorPush title:columnItem.name];
                row.selectorTitle = columnItem.name;    // 进去单选界面的title
                if ([columnItem.required integerValue]) {
                    row.noValueDisplayText = @"点击填写";
                }else {
                    row.noValueDisplayText = @"必填";
                }
                NSMutableArray *optionsArray = [[NSMutableArray alloc] initWithCapacity:columnItem.selectArray.count];
                for (ColumnSelectModel *tempSelect in columnItem.selectArray) {
                    XLFormOptionsObject *object = [XLFormOptionsObject formOptionsObjectWithValue:tempSelect.id displayText:tempSelect.value];
                    [optionsArray addObject:object];
                    
                    if ([columnItem.stringResult isEqualToString:tempSelect.id]) {
                        row.value = object;
                    }
                }
                row.selectorOptions = optionsArray;
                row.hidden = columnItem.showWhenInit;
                row.disabled = columnItem.editAble;
                [section addFormRow:row];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - event response
- (void)backButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemPress {
    // 获取json串
    NSMutableArray *jsonArray;
    
    if (![self getJsonArrayWithColumnsArray:_customerArray]) {
        return;
    }
    
    jsonArray = [self getJsonArrayWithColumnsArray:_customerArray];
    
    if (_isExpend) {
        if (![self getJsonArrayWithColumnsArray:_saleChanceArray]) {
            return;
        }
        
        [jsonArray addObjectsFromArray:[self getJsonArrayWithColumnsArray:_saleChanceArray]];
    }
    
    SBJson4Writer *jsonParser = [[SBJson4Writer alloc] init];
    
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempParams setObject:[jsonParser stringWithObject:jsonArray] forKey:@"json"];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Lead_ChangeToCustomer_WithParams:tempParams block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[LeadViewController class]]) {
                    LeadViewController *leadController = (LeadViewController*)controller;
                    [leadController deleteAndRefreshDataSource];
                    [self.navigationController popToViewController:leadController animated:YES];
                    break;
                }
                
                if ([controller isKindOfClass:[LeadListViewController class]]) {
                    LeadListViewController *leadListController = (LeadListViewController*)controller;
                    [leadListController deleteAndRefreshDataSource];
                    [self.navigationController popToViewController:leadListController animated:YES];
                    break;
                }
            }

        }
    }];
}

- (void)addMoreButtonPress {
    
    _isExpend = YES;
    
    [self configXLFormWithArray:_saleChanceArray];
    
    self.tableView.tableFooterView = nil;
}

#pragma mark - private method
- (NSMutableArray*)getJsonArrayWithColumnsArray:(NSArray*)columnsArray {
    NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:0];
    for (ColumnModel *tempItem in columnsArray) {
        // 将未显示的排除
        if ([tempItem.showWhenInit isEqualToNumber:@1]) {
            continue;
        }
        // 将section排除
        if ([tempItem.columnType isEqualToNumber:@8]) {
            continue;
        }
        // 对象类型
        if ([tempItem.columnType isEqualToNumber:@10]) {
            continue;
        }
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setObject:tempItem.propertyName forKey:@"propertyName"];
        [tempDict setObject:tempItem.columnType forKey:@"columnType"];
        [tempDict setObject:tempItem.object forKey:@"object"];
        if ([tempItem.columnType isEqualToNumber:@3]) {  // 单选
            // 必填项
            if ([tempItem.required isEqualToNumber:@0] && !tempItem.stringResult) {
                [self showAlertViewWithString:tempItem.name];
                return nil;
            }
            
            // 选填项
            [tempDict setObject:(tempItem.stringResult ? : @"") forKey:@"result"];
        }
        else if ([tempItem.columnType isEqualToNumber:@4]) {  // 多选
            // 必填项
            if ([tempItem.required isEqualToNumber:@0] && !tempItem.arrayResult) {
                [self showAlertViewWithString:tempItem.name];
                return nil;
            }
            
            // 选填项
            NSString *string = @"";
            for (int i = 0; i < tempItem.arrayResult.count; i ++) {
                NSString *str = tempItem.arrayResult[i];
                if (i) {
                    string = [NSString stringWithFormat:@"%@,%@", string, str];
                }
                else {
                    string = str;
                }
            }
            [tempDict setObject:string forKey:@"result"];
        }
        else if ([tempItem.columnType isEqualToNumber:@7]) {  // 日期
            // 必填项
            if ([tempItem.required isEqualToNumber:@0] && !tempItem.dateResult) {
                [self showAlertViewWithString:tempItem.name];
                return nil;
            }
            
            // 选填项
            NSDate *date = tempItem.dateResult;
            
            NSString *timeStr = [date stringYearMonthDayForLine];
            [tempDict setObject:(timeStr ? : @"") forKey:@"result"];
        }
        else {
            // 必填项
            if ([tempItem.required isEqualToNumber:@0] && !tempItem.stringResult) {
                [self showAlertViewWithString:tempItem.name];
                return nil;
            }
            
            // 选填项
            [tempDict setObject:(tempItem.stringResult ? : @"") forKey:@"result"];
        }
        [jsonArray addObject:tempDict];
    }
    
    return jsonArray;
}

- (void)showAlertViewWithString:(NSString*)str {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"%@不能为空", str] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:confirmAction];
    [kKeyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - XLFormDescriptorDelegate
- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:_customerArray];
    [tempArray addObjectsFromArray:_saleChanceArray];
    for (ColumnModel *column in tempArray) {
        if ([[NSString stringWithFormat:@"%@_%@", column.object, column.propertyName] isEqualToString:formRow.tag]) {
            
            switch ([column.columnType integerValue]) {
                case 1: {  // 文本
                    column.stringResult = newValue;
                }
                    break;
                case 2: {  // 文本域
                    column.stringResult = newValue;
                }
                    break;
                case 3: {  // 单选
                    if ([column.type isEqualToNumber:@203]) {
                        column.stringResult = [newValue formValue];
                    }else {
                        XLFormOptionsObject *option = newValue;
                        column.stringResult = [option formValue];
                    }
                }
                    break;
                case 4: {  // 多选
                    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                    for (XLFormOptionsObject *option in (NSArray*)newValue) {
                        [tempArray addObject:[NSString stringWithFormat:@"%@", [option formValue]]];
                    }
                    column.arrayResult = tempArray;
                }
                    break;
                case 5: {  // 整数
                    column.stringResult = [NSString stringWithFormat:@"%@", newValue];
                }
                    break;
                case 6: {  // 浮点数
                    column.stringResult = [NSString stringWithFormat:@"%@", newValue];
                }
                    break;
                case 7: {  // 日期
                    if ([oldValue isEqual:[NSNull null]]) {
                        column.dateResult = newValue;
                        [self updateFormRow:formRow];
                    }
                    else {
                        column.dateResult = newValue;
                    }
                }
                    break;
                case 100: {  // 所属部门
                    XLFormOptionsObject *option = newValue;
                    column.stringResult = [option formValue];
                }
                default:
                    break;
            }
            
            break;
        }
    }
}

#pragma mark - UITableView_M
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5f;
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
