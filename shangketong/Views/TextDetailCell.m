//
//  TextDetailCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TextDetailCell.h"
#import "InputDatePickerView.h"
#import "InputAccessoryView.h"
#import "InputPickerView.h"

#define kPaddingLeftWidth   15
#define kTextFont           14
#define kDetailFont         14
#define kTextColor          [UIColor blackColor]
#define kDetailColor        [UIColor lightGrayColor]

@interface TextDetailCell ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *m_textLabel;
@property (nonatomic, strong) UITextField *m_detailField;
@property (nonatomic, strong) UIView *m_view;   // 遮罩
@end

@implementation TextDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        _isAccessoryView = NO;
        _isEdit = YES;
        
        [self.contentView addSubview:self.m_textLabel];
        [self.contentView addSubview:self.m_detailField];
        [self.contentView addSubview:self.m_view];
    }
    return self;
}

- (void)configWithText:(NSString *)textStr andDetail:(NSString *)detailStr andInputViewType:(TextFieldInputViewType)type andSourceArray:(NSArray *)sourceArray {
    _m_textLabel.text = textStr;
    _m_detailField.placeholder = detailStr;
    
    if (_isAccessoryView) {
        InputAccessoryView *inputView = [InputAccessoryView sharedAccessoryView];
        _m_detailField.inputAccessoryView = inputView;
    }else {
        _m_detailField.inputAccessoryView = nil;
    }
    
    if (_isEdit) {
        _m_view.hidden = YES;

        switch (type) {
            case TextFieldInputViewTypeDefault:
            {
                _m_detailField.keyboardType = UIKeyboardTypeDefault;
                _m_detailField.inputView = nil;
            }
                break;
            case TextFieldInputViewTypeDecimalPad:
            {
                _m_detailField.keyboardType = UIKeyboardTypeDecimalPad;
                _m_detailField.inputView = nil;
            }
                break;
            case TextFieldInputViewTypeDatePickerView:
            {
                InputDatePickerView *datePickerView = [InputDatePickerView sharedDatePickerView];
                _m_detailField.inputView = datePickerView;
            }
                break;
            case TextFieldInputViewTypePickerView:
            {
                InputPickerView *pickerView = [InputPickerView sharedPickerView];
                pickerView.sourceArray = sourceArray;
                _m_detailField.inputView = pickerView;
            }
                break;
            default:
                break;
        }
        
        
    }else {
        _m_view.hidden = NO;
    }
}

+ (CGFloat)cellHeight {
    return 44.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return _isEdit;
}

#pragma mark - setters and getters
- (void)setIsEdit:(BOOL)isEdit {
    _isEdit = isEdit;
    if ([self respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        [self textFieldShouldBeginEditing:_m_detailField];
    }
}

- (UILabel*)m_textLabel {
    if (!_m_textLabel) {
        _m_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([TextDetailCell cellHeight] - 30)/2.0, 150, 30)];
        _m_textLabel.font = [UIFont systemFontOfSize:kTextFont];
        _m_textLabel.textColor = kTextColor;
        _m_textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_textLabel;
}

- (UITextField*)m_detailField {
    if (!_m_detailField) {
        
        _m_detailField = [[UITextField alloc] initWithFrame:CGRectMake(kScreen_Width - 30 - 150, 0, 150, [TextDetailCell cellHeight])];
        _m_detailField.delegate = self;
        _m_detailField.font = [UIFont systemFontOfSize:kDetailFont];
        _m_detailField.textColor = kDetailColor;
        _m_detailField.textAlignment = NSTextAlignmentRight;

    }
    return _m_detailField;
}

- (UIView*)m_view {
    if (!_m_view) {
        _m_view = [[UIView alloc] initWithFrame:_m_detailField.frame];
    }
    return _m_view;
}

@end
