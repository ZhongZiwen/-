//
//  XLEditScheduleDetailCell.m
//  shangketong
//
//  Created by 蒋 on 15/12/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLEditScheduleDetailCell.h"
#import "XLFScheduleTypeViewController.h"
#import <XLForm.h>
#import "CommonFuntion.h"

NSString *const XLFormRowDescriptorTypeEditScheduleDetail = @"XLFormRowDescriptorTypeEditScheduleDetail";

@interface XLEditScheduleDetailCell ()<UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *typeIView;
@property (nonatomic, strong) UITextField *themeField;
@property (nonatomic, strong) UILabel *selectorLabel;
@end

@implementation XLEditScheduleDetailCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLEditScheduleDetailCell class] forKey:XLFormRowDescriptorTypeEditScheduleDetail];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.typeIView];
    [self.contentView addSubview:self.themeField];
    [self.contentView addSubview:self.selectorLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(kScreen_Width - 80.5, 0, 0.5, 44)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:line];
}

- (void)update {
    [super update];
    
    NSDictionary *sourceDict = self.rowDescriptor.value;
    
    _typeIView.image = [CommonFuntion createImageWithColor:[CommonFuntion getColorValueByColorType:[sourceDict[@"type"] integerValue]]];
    _themeField.text = sourceDict[@"name"];
    _selectorLabel.text = sourceDict[@"typeName"];
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

#pragma mark - UITextFieldDelegate
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    NSMutableDictionary *dict = [self.rowDescriptor.value mutableCopy];
//    [dict setObject:textField.text forKey:@"name"];
//
//    self.rowDescriptor.value = dict;
//}

-(void)textchange:(UITextField *)textField {
    NSMutableDictionary *dict = [self.rowDescriptor.value mutableCopy];
    [dict setObject:textField.text forKey:@"name"];
    
    self.rowDescriptor.value = dict;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.themeField) {
        if (string.length == 0) return YES;
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 30) {
            return NO;
        }
    }
    
    return YES;
}
#pragma mark - setters and getters
- (UIImageView*)typeIView {
    if (!_typeIView) {
        _typeIView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (44-5)/2.0, 8, 8)];
        _typeIView.contentMode = UIViewContentModeScaleAspectFill;
        _typeIView.clipsToBounds = YES;
        _typeIView.layer.cornerRadius = _typeIView.frame.size.height/2;
    }
    return _typeIView;
}

- (UITextField*)themeField {
    if (!_themeField) {
        _themeField  = [[UITextField alloc] initWithFrame:CGRectMake(2*15+CGRectGetWidth(_typeIView.bounds), 0, kScreen_Width - 2*15 - CGRectGetWidth(_typeIView.bounds) - 80, 44)];
        _themeField.font = [UIFont systemFontOfSize:14];
        _themeField.placeholder = @"日程名称（必填）";
        _themeField.textAlignment = NSTextAlignmentLeft;
        //        _themeField.clearsOnBeginEditing = YES;
        //        _themeField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _themeField.delegate = self;
        
        [_themeField addTarget:self action:@selector(textchange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _themeField;
}

- (UILabel*)selectorLabel {
    if (!_selectorLabel) {
        _selectorLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 80, 0, 80, 44)];
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
