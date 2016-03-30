//
//  XLFormTaskTitleCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormTaskTitleCell.h"
#import "TaskDetail.h"

#define kPaddingLeftWidth 15

NSString *const XLFormRowDescriptorTypeTaskTitle = @"XLFormRowDescriptorTypeTaskTitle";

@interface XLFormTaskTitleCell ()

@property (strong, nonatomic) UIButton *statusButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *editButton;
@end

@implementation XLFormTaskTitleCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFormTaskTitleCell class] forKey:XLFormRowDescriptorTypeTaskTitle];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.statusButton];
    [self.contentView addSubview:self.titleLabel];
//    [self.contentView addSubview:self.editButton];
}

- (void)update {
    [super update];
    
    TaskDetail *value = self.rowDescriptor.value;
    
    NSString *imageStr = [value.taskStatus integerValue] == 1 ? @"home_today_task" : @"home_today_task_done";
    [_statusButton setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
    _titleLabel.text = value.name;
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 44.0f;
}

#pragma mark - setters and getters
- (UIButton*)statusButton {
    if (!_statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_statusButton setWidth:44.0f];
        [_statusButton setHeight:44.0f];
        
    }
    return _statusButton;
}


- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setX:CGRectGetMaxX(_statusButton.frame)];
        [_titleLabel setWidth:kScreen_Width - CGRectGetMinX(_titleLabel.frame) - 44];
        [_titleLabel setHeight:44.0f];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UIButton*)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setX:kScreen_Width - 44.0f];
        [_editButton setWidth:44.0f];
        [_editButton setHeight:44.0f];
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
