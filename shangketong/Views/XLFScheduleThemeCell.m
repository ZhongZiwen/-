//
//  XLFScheduleThemeCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFScheduleThemeCell.h"
#import <XLForm.h>
#import "ScheduleType.h"

NSString *const XLFormRowDescriptorTypeScheduleTheme = @"XLFormRowDescriptorTypeScheduleTheme";

@interface XLFScheduleThemeCell ()

@property (nonatomic, strong) UIImageView *typeIView;
@property (nonatomic, strong) UITextField *themeField;
@property (nonatomic, strong) UILabel *selectorLabel;
@end

@implementation XLFScheduleThemeCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFScheduleThemeCell class] forKey:XLFormRowDescriptorTypeScheduleTheme];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.typeIView];
    [self.contentView addSubview:self.themeField];
    [self.contentView addSubview:self.selectorLabel];
    
    UIImageView *line = [[UIImageView alloc] init];
    [line setX:kScreen_Width - 80.5];
    [line setWidth:0.5];
    [line setHeight:44.0f];
    line.image = [UIImage imageWithColor:[UIColor iOS7lightGrayColor]];
    [self.contentView addSubview:line];
}

- (void)update {
    [super update];
    
    ScheduleType *item = self.rowDescriptor.value;
    
    _typeIView.image = [UIImage imageWithColor:[UIColor colorWithColorType:item.color]];
    _themeField.text = item.title;
    _selectorLabel.text = item.name ? : @"选择类型";
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    
    BOOL hasAction = self.rowDescriptor.action.formBlock || self.rowDescriptor.action.formSelector;
    if (hasAction) {
        if (self.rowDescriptor.action.formBlock) {
            self.rowDescriptor.action.formBlock(self.rowDescriptor);
        }
    }
    
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 44.0f;
}

#pragma mark - event response
-(void)textchange:(UITextField *)textField {
    
    if (textField.text.length > MAX_LIMIT_TEXTFIELD_SPE) {
        textField.text = [textField.text substringToIndex:MAX_LIMIT_TEXTFIELD_SPE];
    }
    
    ScheduleType *item = self.rowDescriptor.value;
    item.title = textField.text;
    
    self.rowDescriptor.value = item;
}

#pragma mark - setters and getters
- (UIImageView*)typeIView {
    if (!_typeIView) {
        _typeIView = [[UIImageView alloc] init];
        [_typeIView setX:15];
        [_typeIView setWidth:8];
        [_typeIView setHeight:8];
        [_typeIView setCenterY:44.0f / 2];
        [_typeIView doCircleFrame];
    }
    return _typeIView;
}

- (UITextField*)themeField {
    if (!_themeField) {
        _themeField  = [[UITextField alloc] init];
        [_themeField setX:CGRectGetMaxX(_typeIView.frame) + 10];
        [_themeField setWidth:kScreen_Width - CGRectGetMinX(_themeField.frame) - 85];
        [_themeField setHeight:44.0f];
        _themeField.font = [UIFont systemFontOfSize:16];
        _themeField.placeholder = @"日程名称（必填）";
        _themeField.textAlignment = NSTextAlignmentLeft;
//        _themeField.clearsOnBeginEditing = YES;
//        _themeField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        [_themeField addTarget:self action:@selector(textchange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _themeField;
}

- (UILabel*)selectorLabel {
    if (!_selectorLabel) {
        _selectorLabel = [[UILabel alloc] init];
        [_selectorLabel setX:kScreen_Width - 80];
        [_selectorLabel setWidth:80];
        [_selectorLabel setHeight:44.0f];
        _selectorLabel.font = [UIFont systemFontOfSize:14];
        _selectorLabel.textColor = [UIColor blackColor];
        _selectorLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _selectorLabel;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
