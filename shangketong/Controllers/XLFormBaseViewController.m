//
//  XLFormBaseViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormBaseViewController.h"
#import "MySBJsonWriter.h"
#import "ColumnMoreViewController.h"
#import "XLFormCustomTextViewCell.h"
#import "XLFormCustomDateCell.h"
#import "DateAndTimeValueTrasformer.h"
// 客户选择
#import "ContactNewSearchViewController.h"
#import "Customer.h"

@interface XLFormBaseViewController ()

@end

@implementation XLFormBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    self.form = form;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 限制textField字数
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > MAX_LIMIT_TEXTFIELD) {
        textField.text = [textField.text substringToIndex:MAX_LIMIT_TEXTFIELD];
    }
}

#pragma mark - public method
- (void)configXLForm {
    
    // 删除原表单
    while (self.form.formSections.count) {
        // remove last section
        [self.form removeFormSectionAtIndex:(self.form.formSections.count - 1)];
    }
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    for (ColumnModel *columnItem in _sourceArray) {
        
        switch ([columnItem.columnType integerValue]) {
            case 1: {   // 文本
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.propertyName rowType:XLFormRowDescriptorTypeText title:columnItem.name];
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
                
                NSIndexPath *indexPath = [self.form indexPathOfFormRow:row];
                XLFormTextFieldCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            }
                break;
            case 2: {   // 文本域
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.propertyName rowType:XLFormRowDescriptorTypeCustomTextView];
                [row.cellConfigAtConfigure setObject:columnItem.name forKey:@"titleLabel.text"];
                if ([columnItem.required integerValue]) {
                    [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textView.placeholder"];
                }
                else {
                    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textView.placeholder"];
                }
                row.hidden = columnItem.showWhenInit;
                if (columnItem.stringResult) {
                    row.value = columnItem.stringResult;
                }
                row.disabled = columnItem.editAble;
                [section addFormRow:row];
//                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.propertyName rowType:XLFormRowDescriptorTypeTextView];
//                if ([columnItem.required integerValue]) {
//                    [row.cellConfigAtConfigure setObject:columnItem.name forKey:@"textView.placeholder"];
//                }else {
//                    [row.cellConfigAtConfigure setObject:[NSString stringWithFormat:@"%@(必填)", columnItem.name] forKey:@"textView.placeholder"];
//                }
//                row.hidden = columnItem.showWhenInit;
//                if (columnItem.stringResult) {
//                    row.value = columnItem.stringResult;
//                }
//                row.disabled = columnItem.editAble;
//                [section addFormRow:row];
            }
                break;
            case 3: {   // 单选框
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.propertyName rowType:XLFormRowDescriptorTypeSelectorPush title:columnItem.name];
                row.selectorTitle = columnItem.name;    // 进去单选界面的title
                if ([columnItem.type isEqualToNumber:@203]) {
                    row.selectorTitle = nil;
                    row.action.viewControllerClass = [ContactNewSearchViewController class];
                }
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
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.propertyName rowType:XLFormRowDescriptorTypeMultipleSelector title:columnItem.name];
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
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.propertyName rowType:XLFormRowDescriptorTypeInteger title:columnItem.name];
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
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.propertyName rowType:XLFormRowDescriptorTypeDecimal title:columnItem.name];
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
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.propertyName rowType:XLFormRowDescriptorTypeCustomDate title:columnItem.name];
//                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.propertyName rowType:XLFormRowDescriptorTypeDateInline title:columnItem.name];
                [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
                // 开启时分属性
                if (![columnItem.fullDate integerValue]) {
                    [row.cellConfigAtConfigure setObject:@(XLFormCustomDateDatePickerModeDateTime) forKey:@"formDatePickerMode"];
                    row.valueTransformer = [DateTimeValueTrasformer class];
                }
                if ([columnItem.required integerValue]) {
                    row.noValueDisplayText = @"点击填写";
                }else {
                    row.noValueDisplayText = @"必填";
                    if (!columnItem.dateResult) {
                        row.value = [NSDate date];
                    }
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
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.propertyName rowType:XLFormRowDescriptorTypeSelectorPush title:columnItem.name];
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
    
    NSMutableArray *hiddenSectionsArray = [NSMutableArray arrayWithCapacity:0];
    for (XLFormSectionDescriptor *sectionDescriptor in self.form.formSections) {
        if (!sectionDescriptor.formRows.count) {
            [hiddenSectionsArray addObject:sectionDescriptor];
        }
    }
    
    for (XLFormSectionDescriptor *sectionDescriptor in hiddenSectionsArray) {
        sectionDescriptor.hidden = @1;
    }
    
    // 添加更多信息
    for (ColumnModel *tempItem in _sourceArray) {
        if ([tempItem.showWhenInit isEqualToNumber:@1]) {
            @weakify(self);
            section = [self.form formSections].lastObject;
            row = [XLFormRowDescriptor formRowDescriptorWithTag:@"more" rowType:XLFormRowDescriptorTypeButton title:@"＋添加更多信息"];
            [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"textLabel.textColor"];
            [row.cellConfig setObject:[UIFont systemFontOfSize:14] forKey:@"textLabel.font"];
            row.action.formBlock = ^(XLFormRowDescriptor *rowDescriptor) {
                @strongify(self);
                ColumnMoreViewController *moreController = [[ColumnMoreViewController alloc] init];
                moreController.sourceArray = self.sourceArray;
                moreController.confireBlock = ^{
                    [self configXLForm];
                };
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:moreController];
                [self presentViewController:nav animated:YES completion:nil];
                
                [self deselectFormRow:rowDescriptor];
            };
            [section addFormRow:row];
            break;
        }
    }
}

- (NSString*)jsonString {
    NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:0];
    for (ColumnModel *tempItem in _sourceArray) {
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
            
            NSString *timeStr;
            if (![tempItem.fullDate integerValue]) {
                timeStr = [date stringTimestamp];
            }
            else {
                timeStr = [date stringYearMonthDayForLine];
            }
            [tempDict setObject:(timeStr ? : @"") forKey:@"result"];
        }
        else {
            // 必填项
            if ([tempItem.required isEqualToNumber:@0] && !tempItem.stringResult) {
                [self showAlertViewWithString:tempItem.name];
                return nil;
            }
            
            // 选填项
            if ([tempItem.type isEqualToNumber:@203] && _customerId) {
                [tempDict setObject:_customerId forKey:@"result"];
            }else {
                [tempDict setObject:(tempItem.stringResult ? : @"") forKey:@"result"];
            }
        }
        [jsonArray addObject:tempDict];
    }
    
    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc] init];
    return [jsonParser stringWithObject:jsonArray];
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
    
    for (ColumnModel *column in _sourceArray) {
        if ([column.propertyName isEqualToString:formRow.tag]) {
            
            switch ([column.columnType integerValue]) {
                case 1: {  // 文本
                    
                    if ([(NSString *)newValue length] > 10) {
                        formRow.value = [newValue substringToIndex:10];
//                        cell.textField.text = [newValue substringToIndex:10];
                    }
                    
                    if (newValue != [NSNull null]) {
                        column.stringResult = newValue;
                    }
                    else {
                        column.stringResult = nil;
                    }
                }
                    break;
                case 2: {  // 文本域
                    if (newValue != [NSNull null]) {
                        column.stringResult = newValue;
                    }
                    else {
                        column.stringResult = nil;
                    }
                }
                    break;
                case 3: {  // 单选
                    if ([column.type isEqualToNumber:@203]) {
                        if ([newValue formValue] != [NSNull null]) {
                            column.stringResult = [newValue formValue];
                        }
                        else {
                            column.stringResult = nil;
                        }
                    }else {
                        XLFormOptionsObject *oldOption = oldValue;
                        XLFormOptionsObject *newOption = newValue;
                        if (![newOption isEqual:[NSNull null]]) {
                            column.stringResult = [newOption formValue];
                        }
                        else {
                            if ([column.required isEqualToNumber:@0]) {
                                formRow.value = oldOption;
                            }
                            else {
                                column.stringResult = nil;
                            }
                        }
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
                    if (newValue != [NSNull null]) {
                        column.stringResult = [NSString stringWithFormat:@"%@", newValue];
                    }
                    else {
                        column.stringResult = nil;
                    }
                }
                    break;
                case 6: {  // 浮点数
                    if (newValue != [NSNull null]) {
                        column.stringResult = [NSString stringWithFormat:@"%@", newValue];
                    }
                    else {
                        column.stringResult = nil;
                    }
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
                    XLFormOptionsObject *oldOption = oldValue;
                    XLFormOptionsObject *newOption = newValue;
                    if (![newOption isEqual:[NSNull null]]) {
                        column.stringResult = [newOption formValue];
                    }
                    else {
                        if ([column.required isEqualToNumber:@0]) {
                            formRow.value = oldOption;
                        }
                        else {
                            column.stringResult = nil;
                        }
                    }
                }
                default:
                    break;
            }
            
            break;
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
