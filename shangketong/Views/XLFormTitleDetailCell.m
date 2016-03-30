//
//  XLFormTitleDetailCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormTitleDetailCell.h"
#import "ColumnModel.h"
#import "ColumnSelectModel.h"

#define kPaddingLeftWidth 15
#define kTextFont_title   [UIFont systemFontOfSize:16]
#define kTextFont_detail  [UIFont systemFontOfSize:16]

NSString *const XLFormRowDescriptorTypeTitleDetail = @"XLFormRowDescriptorTypeTitleDetail";

@interface XLFormTitleDetailCell ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIButton *editButton;
@end

@implementation XLFormTitleDetailCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFormTitleDetailCell class] forKey:XLFormRowDescriptorTypeTitleDetail];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
//    [self.contentView addSubview:self.editButton];
}

- (void)update {
    [super update];
    
    ColumnModel *value = self.rowDescriptor.value;
    
    _titleLabel.text = value.name;

    //(0, "未定义类型")(1, "文本类型")(2," 文本区域类型")(3,"单选类型")(4,"多选类型")(5,"整数类型")(6,"浮点类型")(7,"日期类型")(8,"分割线类型")(9,"自动编号"--客户端不显示)(10,"对象类型")(100,表示部门)
    
    NSString *detailStr;
    if ([value.columnType integerValue] == 1 || [value.columnType integerValue] == 2 || [value.columnType integerValue] == 5 || [value.columnType integerValue] == 6) {
        if (value.stringResult) {
            detailStr = value.stringResult;
        }
    }
    else if ([value.columnType integerValue] == 7) {  // 日期型
        if (value.dateResult) {
            detailStr = [value.dateResult stringTimestamp];
        }
    }
    else if ([value.columnType integerValue] == 3) {  // 单选
        if (value.stringResult) {
            for (ColumnSelectModel *selectModel in value.selectArray) {
                if ([value.stringResult isEqualToString:selectModel.id]) {
                    detailStr = selectModel.value;
                    break;
                }
            }
        }
    }
    else if ([value.columnType integerValue] == 4) {  // 多选
        for (int i = 0; i < value.arrayResult.count; i ++) {
            NSString *tempStr = value.arrayResult[i];
            for (ColumnSelectModel *tempSelect in value.selectArray) {
                if ([tempStr isEqualToString:tempSelect.id]) {
                    detailStr = (i == 0 ? tempSelect.value : [NSString stringWithFormat:@"%@,%@", detailStr, tempSelect.value]);
                }
            }
        }
    }

    if (detailStr && detailStr.length) {
        CGFloat height = [detailStr getHeightWithFont:kTextFont_detail constrainedToSize:CGSizeMake(kScreen_Width - 2 * kPaddingLeftWidth, CGFLOAT_MAX)];
        if (height > 20) {
            [_detailLabel setHeight:height];
        }else {
            [_detailLabel setHeight:20];
        }
        _detailLabel.textColor = [UIColor blackColor];
        _detailLabel.text = detailStr;
    }else {
        _detailLabel.textColor = [UIColor iOS7lightGrayColor];
        _detailLabel.text = @"未填写";
        [_detailLabel setHeight:20];
    }
    
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    ColumnModel *item = rowDescriptor.value;
    
    NSString *detailStr;
    if ([item.columnType integerValue] == 1 || [item.columnType integerValue] == 2 || [item.columnType integerValue] == 5 || [item.columnType integerValue] == 6) {
        detailStr = item.stringResult;
    }
    else if ([item.columnType integerValue] == 7) {  // 日期型
        if (item.dateResult) {
            detailStr = [item.dateResult stringTimestamp];
        }
    }
    else if ([item.columnType integerValue] == 3) {  // 单选
        if (item.stringResult) {
            for (ColumnSelectModel *selectModel in item.selectArray) {
                if ([item.stringResult isEqualToString:selectModel.id]) {
                    detailStr = selectModel.value;
                    break;
                }
            }
        }
    }
    else if ([item.columnType integerValue] == 4) {  // 多选
        for (int i = 0; i < item.arrayResult.count; i ++) {
            NSString *tempStr = item.arrayResult[i];
            for (ColumnSelectModel *tempSelect in item.selectArray) {
                if ([tempStr isEqualToString:tempSelect.id]) {
                    detailStr = (i == 0 ? tempSelect.value : [NSString stringWithFormat:@"%@,%@", detailStr, tempSelect.value]);
                }
            }
        }
    }
    
    CGFloat height = 10 + 20 + 10 + 10;
    if (detailStr && detailStr.length) {
        CGFloat h = [detailStr getHeightWithFont:kTextFont_detail constrainedToSize:CGSizeMake(kScreen_Width - 2 * kPaddingLeftWidth, CGFLOAT_MAX)];
        if (h > 20) {
            height += h;
        }else {
            height += 20;
        }
    }else {
        height += 20;
    }
    return height;
}

#pragma mark - setters and getters
- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setX:kPaddingLeftWidth];
        [_titleLabel setY:10];
        [_titleLabel setWidth:kScreen_Width - 2 * kPaddingLeftWidth];
        [_titleLabel setHeight:20];
        _titleLabel.font = kTextFont_title;
        _titleLabel.textColor = [UIColor iOS7lightBlueColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setX:CGRectGetMinX(_titleLabel.frame)];
        [_detailLabel setY:CGRectGetMaxY(_titleLabel.frame) + 10];
        [_detailLabel setWidth:CGRectGetWidth(_titleLabel.bounds)];
        _detailLabel.font = kTextFont_detail;
        _detailLabel.textColor = [UIColor blackColor];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.numberOfLines = 0;
        _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _detailLabel;
}

- (UIButton*)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_editButton setImage:[UIImage imageNamed:@"edit_doc"] forState:UIControlStateNormal];
    }
    return _editButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
