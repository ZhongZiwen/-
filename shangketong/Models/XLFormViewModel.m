//
//  XLFormViewModel.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewModel.h"
#import <XLForm.h>
#import "MySBJsonWriter.h"
#import "ColumnModel.h"
#import "ColumnSelectModel.h"
#import "ContactNewSearchViewController.h"
#import "Customer.h"

@implementation XLFormViewModel

- (instancetype)initWithSourceArray:(NSMutableArray *)array moreColumsArray:(NSMutableArray *)moreArray {
    self = [super init];
    if (self) {
        self.sourceArray = array;
        self.moreColumns = moreArray;
        
        self.formDescriptor = [XLFormDescriptor formDescriptor];
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
                    row.value = columnItem.stringResult;
                    row.disabled = columnItem.editAble;
                    [section addFormRow:row];
                }
                    break;
                case 2: {   // 文本域
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.propertyName rowType:XLFormRowDescriptorTypeTextView];
                    if ([columnItem.required integerValue]) {
                        [row.cellConfigAtConfigure setObject:columnItem.name forKey:@"textView.placeholder"];
                    }else {
                        [row.cellConfigAtConfigure setObject:[NSString stringWithFormat:@"%@(必填)", columnItem.name] forKey:@"textView.placeholder"];
                    }
                    row.hidden = columnItem.showWhenInit;
                    row.value = columnItem.stringResult;
                    row.disabled = columnItem.editAble;
                    [section addFormRow:row];
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
                        
                        if ([[NSString stringWithFormat:@"%@", columnItem.stringResult] isEqualToString:tempSelect.id]) {
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
                    for (ColumnSelectModel *tempSelect in columnItem.selectArray) {
                        XLFormOptionsObject *object = [XLFormOptionsObject formOptionsObjectWithValue:tempSelect.id displayText:tempSelect.value];
                        [optionsArray addObject:object];
                    }
                    row.selectorOptions = optionsArray;
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
                    row.value = @([columnItem.stringResult integerValue]);
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
                    row.value = @([columnItem.stringResult integerValue]);
                    row.disabled = columnItem.editAble;
                    [section addFormRow:row];
                }
                    break;
                case 7: {   // 日期
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.propertyName rowType:XLFormRowDescriptorTypeDateInline title:columnItem.name];
                    [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
                    if ([columnItem.required integerValue]) {
                        row.noValueDisplayText = @"点击填写";
                    }else {
                        row.noValueDisplayText = @"必填";
                        row.value = [NSDate date];
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
                    [self.formDescriptor addFormSection:section];
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
                        
                        if ([[NSString stringWithFormat:@"%@", columnItem.objectResult.id] isEqualToString:tempSelect.id]) {
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
        
        // 添加更多信息
        if (_moreColumns.count) {
            row = [XLFormRowDescriptor formRowDescriptorWithTag:@"more" rowType:XLFormRowDescriptorTypeButton title:@"＋添加更多信息"];
            [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"textLabel.textColor"];
            [row.cellConfig setObject:[UIFont systemFontOfSize:14] forKey:@"textLabel.font"];
            row.action.formBlock = ^(XLFormRowDescriptor *sender) {
                
                if (self.deselectBlock) {
                    self.deselectBlock(sender);
                }
            };
            [section addFormRow:row];
        }
        
        NSMutableArray *hiddenSectionsArray = [NSMutableArray arrayWithCapacity:0];
        for (XLFormSectionDescriptor *sectionDescriptor in self.formDescriptor.formSections) {
            if (!sectionDescriptor.formRows.count) {
                [hiddenSectionsArray addObject:sectionDescriptor];
            }
        }
        
        for (XLFormSectionDescriptor *sectionDescriptor in hiddenSectionsArray) {
            sectionDescriptor.hidden = @1;
        }
    }
    return self;
}

- (void)refreshForm {
    NSMutableArray *selectedArray = [NSMutableArray arrayWithCapacity:0];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    for (ColumnModel *tempItem in _moreColumns) {
        if ([tempItem.showWhenInit integerValue]) continue;
        
        row = [_formDescriptor formRowWithTag:tempItem.propertyName];
        row.hidden = @0;
        
        NSIndexPath *indexPath = [_formDescriptor indexPathOfFormRow:row];
        section = [_formDescriptor formSectionAtIndex:indexPath.section];
        section.hidden = @0;
        
        [selectedArray addObject:tempItem];
    }
    
    [_moreColumns removeObjectsInArray:selectedArray];
    
    if (_moreColumns.count) return;
    
    row = [_formDescriptor formRowWithTag:@"more"];
    row.hidden = @1;
}

- (NSString*)jsonString {
    // 获取json串
    NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (ColumnModel *column in _sourceArray) {
        // 将未显示的排除
        if ([column.showWhenInit integerValue]) continue;
        // 将section排除
        if ([column.columnType integerValue] == 8) continue;
        
        if ([column.columnType integerValue] == 10) continue;
        
        // 单选
        if ([column.columnType integerValue] == 3) {
            NSDictionary *tempDict = [self getValueFromSelectorsWithModel:column];
            if (tempDict) {
                [jsonArray addObject:tempDict];
            }else {
                [self showAlertViewWithString:column.name];
                return nil;
            }
            continue;
        }
        
        // 多选
        if ([column.columnType integerValue] == 4) {
            NSDictionary *tempDict = [self getValueFromMultipleSelectorsWithModel:column];
            if (tempDict) {
                [jsonArray addObject:tempDict];
            }else {
                [self showAlertViewWithString:column.name];
                return nil;
            }
            continue;
        }
        
        // 日期
        if ([column.columnType integerValue] == 7) {
            NSDictionary *tempDict = [self getValueFromDateWithModel:column];
            if (tempDict) {
                [jsonArray addObject:tempDict];
            }else {
                [self showAlertViewWithString:column.name];
                return nil;
            }
            continue;
        }
        
        // 所属部门
        if ([column.columnType integerValue] == 100) {
            NSDictionary *tempDict = [self getValueFromSelectorsWithModel:column];
            if (tempDict) {
                [jsonArray addObject:tempDict];
            }else {
                
                [self showAlertViewWithString:column.name];
                return nil;
            }
            continue;
        }
        
        // 文本、文本域和其它
        NSDictionary *tempDict = [self getValueFromOtherWithModel:column];
        if (tempDict) {
            [jsonArray addObject:tempDict];
        }else {
            [self showAlertViewWithString:column.name];
            return nil;
        }
    }
    
    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
    
    return [jsonParser stringWithObject:jsonArray];
}

#pragma mark - private method
- (void)showAlertViewWithString:(NSString*)str {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"%@不能为空", str] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:confirmAction];
    [kKeyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (NSDictionary*)getValueFromSelectorsWithModel:(ColumnModel*)column {
    XLFormRowDescriptor *row = [_formDescriptor formRowWithTag:column.propertyName];
    
    // 选择公司名称 选填
    if ([column.type isEqualToNumber:@203] && [column.required integerValue]) {
        return @{@"propertyName" : column.propertyName,
                 @"columnType" : column.columnType,
                 @"result" : [row.value formValue] ? : @""};
    }
    
    // 选择公司名称 必填
    if ([column.type isEqualToNumber:@203] && ![column.required integerValue]) {
        if (row.value) {
            return @{@"propertyName" : column.propertyName,
                     @"columnType" : column.columnType,
                     @"result" : [row.value formValue]};
        }else {
            nil;
        }
    }
    
    
    XLFormOptionsObject *optionsObject = row.value;
    // 选填
    if ([column.required integerValue]) {
        return @{@"propertyName" : column.propertyName,
                 @"columnType" : column.columnType,
                 @"result" : optionsObject.formValue ? : @""};
    }
    
    // 必填
    if (optionsObject) {
        return @{@"propertyName" : column.propertyName,
                 @"columnType" : column.columnType,
                 @"result" : optionsObject.formValue};
    }
    
    return nil;
}

- (NSDictionary*)getValueFromMultipleSelectorsWithModel:(ColumnModel*)column {
    NSString *objectString = @"";
    XLFormRowDescriptor *row = [_formDescriptor formRowWithTag:column.propertyName];
    for (int i = 0; i < [row.value count]; i ++) {
        XLFormOptionsObject *optionsObject = row.value[i];
        if (i == 0) {
            objectString = [NSString stringWithFormat:@"%@", optionsObject.formValue];
        }else {
            objectString = [NSString stringWithFormat:@"%@,%@", objectString, optionsObject.formValue];
        }
    }
    
    // 如果是必填项，判断是否为空值
    if (![column.required integerValue] && ![objectString length]) {
        return nil;
    }
    
    return @{@"propertyName" : column.propertyName,
             @"columnType" : column.columnType,
             @"result" : objectString};
}

- (NSDictionary*)getValueFromDateWithModel:(ColumnModel*)column {
    XLFormRowDescriptor *row = [_formDescriptor formRowWithTag:column.propertyName];
    NSString *string = [row.value stringYearMonthDayForLine];
    if (![column.required integerValue] && !string) {
        return nil;
    }
    return @{@"propertyName" : column.propertyName,
             @"columnType" : column.columnType,
             @"result" : string ? : @""};
}

- (NSDictionary*)getValueFromOtherWithModel:(ColumnModel*)column {
    XLFormRowDescriptor *row = [_formDescriptor formRowWithTag:column.propertyName];
    if (![column.required integerValue] && !row.value) {
        return nil;
    }
    
    return @{@"propertyName" : column.propertyName,
             @"columnType" : column.columnType,
             @"result" : ([column.type isEqualToNumber:@203] ? _customerId : (row.value ? : @""))};
}

@end
