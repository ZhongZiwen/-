//
//  EditTitleValueTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EditTitleValueTableViewCell.h"

#define kTitleLabelSizeWidth 70

@interface EditTitleValueTableViewCell ()

@property (nonatomic, weak) UILabel *m_titleLabel;

@end

@implementation EditTitleValueTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellLeftWidth, 10, kTitleLabelSizeWidth, 24)];
        titleLabel.font = [UIFont systemFontOfSize:15];;
        titleLabel.textColor = kCellTitleColor;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _m_titleLabel = titleLabel;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(kCellLeftWidth+kTitleLabelSizeWidth+10, 10, kScreen_Width-kCellLeftWidth-10-10-kTitleLabelSizeWidth, 24)];
        textField.font = [UIFont systemFontOfSize:15];
        textField.textAlignment= NSTextAlignmentRight;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textField addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.contentView addSubview:textField];
        _m_textField = textField;
    }
    return self;
}

- (void)textValueChanged:(UITextField *)sender {
    
    if ([_m_titleLabel.text isEqualToString:@"自我介绍"] || [_m_titleLabel.text isEqualToString:@"业务专长"]) {
        if (sender.text.length > MAX_LIMIT_TEXTVIEW) {
            sender.text = [sender.text substringToIndex:MAX_LIMIT_TEXTVIEW];
        }
    }
    else {
        if (sender.text.length > MAX_LIMIT_TEXTFIELD) {
            sender.text = [sender.text substringToIndex:MAX_LIMIT_TEXTFIELD];
        }
    }
    
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(_m_textField.text);
    }
}

- (void)setTitleLabel:(NSString *)titleStr valueLabel:(NSString *)valueStr
{
    _m_titleLabel.text = titleStr;
    if (![valueStr length]) {
        _m_textField.placeholder = @"未填写";
        return;
    }
    _m_textField.text = valueStr;
}

+ (CGFloat)cellHeight
{
    return 44.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
