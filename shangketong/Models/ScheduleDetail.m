//
//  ScheduleDetail.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ScheduleDetail.h"
#import "ColumnModel.h"
#import <XLForm.h>
#import "XLFormTitleDetailCell.h"
#import "XLFormTitleImagesCell.h"
#import "XLFormScheduleTitleCell.h"

@implementation ScheduleDetail

- (instancetype)init {
    self = [super init];
    if (self) {
        _waitingMembersArray = [[NSMutableArray alloc] initWithCapacity:0];
        _acceptMembersArray = [[NSMutableArray alloc] initWithCapacity:0];
        _rejectMembersArray = [[NSMutableArray alloc] initWithCapacity:0];
        _filesArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)reloadXLForm {
    _formDescriptor = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    // 标题
    section = [XLFormSectionDescriptor formSectionWithTitle:[NSString stringWithFormat:@"该日程于%@由%@创建", [_createdAt stringYearMonthDayForLine], _createdName]];
    [_formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"title" rowType:XLFormRowDescriptorTypeScheduleTitle];
    row.value = self;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [_formDescriptor addFormSection:section];
    // 关联业务
    if (_from) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"from" rowType:XLFormRowDescriptorTypeTitleDetail];
        row.value = [self fromValue];
        [section addFormRow:row];
    }
    
    // 参与人
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"attend" rowType:XLFormRowDescriptorTypeTitleImages];
    row.value = _acceptMembersArray;
    [row.cellConfig setObject:@"参与人" forKey:@"titleLabel.text"];
    [section addFormRow:row];
    
    // 带确认
    if (_waitingMembersArray.count) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"waitingMembers" rowType:XLFormRowDescriptorTypeTitleImages];
        row.value = _waitingMembersArray;
        [row.cellConfig setObject:@"待确认" forKey:@"titleLabel.text"];
        [section addFormRow:row];
    }
    
    // 已拒绝
    if (_rejectMembersArray.count) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"rejectMembers" rowType:XLFormRowDescriptorTypeTitleImages];
        row.value = _rejectMembersArray;
        [row.cellConfig setObject:@"已拒绝" forKey:@"titleLabel.text"];
        [section addFormRow:row];
    }
    
    // 重复
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"repeat" rowType:XLFormRowDescriptorTypeTitleDetail];
    row.value = [self repeatValue];
    [section addFormRow:row];
    
    // 提醒
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"remind" rowType:XLFormRowDescriptorTypeTitleDetail];
    row.value = [self reminderValue];
    [section addFormRow:row];
    
    // 备注
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"remark" rowType:XLFormRowDescriptorTypeTitleDetail];
    row.value = [self remarkValue];
    [section addFormRow:row];
    
    // 私密
    row =[XLFormRowDescriptor formRowDescriptorWithTag:@"private" rowType:XLFormRowDescriptorTypeTitleDetail];
    row.value = [self privateValue];
    [section addFormRow:row];
}


#pragma mark - private method
- (ColumnModel*)fromValue {
    ColumnModel *column = [[ColumnModel alloc] init];
    column.name = @"关联业务";
    column.stringResult = [NSString stringWithFormat:@"%@-%@", _from.sourceName, _from.name];
    column.columnType = @1;
    return column;
}

- (ColumnModel*)repeatValue {
    ColumnModel *column = [[ColumnModel alloc] init];
    column.name = @"重复";
    column.stringResult = nil;
    column.columnType = @1;
    return column;
}

- (ColumnModel*)reminderValue {
    ColumnModel *column = [[ColumnModel alloc] init];
    column.name = @"提醒";
    column.stringResult = nil;
    column.columnType = @1;
    return column;
}

- (ColumnModel*)remarkValue {
    ColumnModel *column = [[ColumnModel alloc] init];
    column.name = @"备注";
    column.stringResult = _descrip ? : @"无备注";
    column.columnType = @1;
    return column;
}

- (ColumnModel*)privateValue {
    ColumnModel *column = [[ColumnModel alloc] init];
    column.name = @"私密";
    column.stringResult = [_isPrivate integerValue] ? @"公开" : @"仅参与人和上级可见";
    column.columnType = @1;
    return column;
}

@end
