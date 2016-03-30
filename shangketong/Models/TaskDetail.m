//
//  TaskDetail.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TaskDetail.h"
#import "ColumnModel.h"
#import <XLForm.h>
#import "XLFormTitleDetailCell.h"
#import "XLFormTitleImagesCell.h"
#import "XLFormTaskTitleCell.h"

@implementation TaskDetail

- (instancetype)init {
    self = [super init];
    if (self) {
        _membersArray = [[NSMutableArray alloc] initWithCapacity:0];
        _filesArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)reloadXLForm {
    _formDescriptor = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    
    // 标题
    section = [XLFormSectionDescriptor formSectionWithTitle:[NSString stringWithFormat:@"该任务于%@由%@创建", [_createdAt stringYearMonthDayForLine], _createdBy.name]];
    [_formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"title" rowType:XLFormRowDescriptorTypeTaskTitle];
    row.value = self;
    [section addFormRow:row];
    
    // 任务描述
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"descrip" rowType:XLFormRowDescriptorTypeTitleDetail];
    row.value = [self descriptionValue];
    [section addFormRow:row];
    
    // 关联业务
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"from" rowType:XLFormRowDescriptorTypeTitleDetail];
    row.value = [self fromValue];
    [section addFormRow:row];
    
    // 责任人
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"owner" rowType:XLFormRowDescriptorTypeTitleImages];
    row.value = @[_owner];
    [row.cellConfig setObject:@"责任人" forKey:@"titleLabel.text"];
    [section addFormRow:row];
    
    // 参与人
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"attend" rowType:XLFormRowDescriptorTypeTitleImages];
    row.value = _membersArray;
    [row.cellConfig setObject:@"参与人" forKey:@"titleLabel.text"];
    [section addFormRow:row];
    
    // 截止时间
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"endTime" rowType:XLFormRowDescriptorTypeTitleDetail];
    row.value = [self endTimeValue];
    [section addFormRow:row];
    
    // 提醒时间
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"remindTime" rowType:XLFormRowDescriptorTypeTitleDetail];
    row.value = [self remindTimeValue];
    [section addFormRow:row];
}

#pragma mark - private method
- (ColumnModel*)descriptionValue {
    ColumnModel *column = [[ColumnModel alloc] init];
    column.name = @"任务描述";
    column.stringResult = _descrip;
    column.columnType = @1;
    return column;
}

- (ColumnModel*)fromValue {
    ColumnModel *column = [[ColumnModel alloc] init];
    column.name = @"关联业务";
    column.stringResult = [NSString stringWithFormat:@"%@-%@", _from.sourceName, _from.name];
    column.columnType = @1;
    return column;
}

- (ColumnModel*)endTimeValue {
    ColumnModel *column = [[ColumnModel alloc] init];
    column.name = @"截止时间";
    column.stringResult = [_date stringTimestamp];
    column.columnType = @1;
    return column;
}

- (ColumnModel*)remindTimeValue {
    NSArray *array = @[@"不提醒", @"准时", @"提前5分钟", @"提前10分钟", @"提前30分钟", @"提前1小时", @"提前2小时", @"提前6小时", @"提前1天", @"提前2天"];
    ColumnModel *column = [[ColumnModel alloc] init];
    column.name = @"提醒时间";
    column.stringResult = array[[_remind integerValue] + 1];
    column.columnType = @1;
    return column;
}
@end
