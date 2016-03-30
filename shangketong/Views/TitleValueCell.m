//
//  TitleValueCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TitleValueCell.h"

#define kTitleLabelSizewidth 70
#define kValueLabelSizeWidth (kScreen_Width-3*kCellLeftWidth-kTitleLabelSizewidth)

@interface TitleValueCell ()

@property (nonatomic, weak) UILabel *m_titleLabel;
@property (nonatomic, weak) UILabel *m_valueLabel;
@end

@implementation TitleValueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryNone;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellLeftWidth, 10, kTitleLabelSizewidth, 24)];
        titleLabel.font = kCellTitleFont;
        titleLabel.textColor = kCellTitleColor;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _m_titleLabel = titleLabel;
        
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width-kCellLeftWidth-kValueLabelSizeWidth, 10, kValueLabelSizeWidth, 0)];
        valueLabel.font = kCellTitleFont;
        valueLabel.textColor = [UIColor lightGrayColor];
        valueLabel.numberOfLines = 0;
        valueLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:valueLabel];
        _m_valueLabel = valueLabel;
    }
    return self;
}

- (void)setTitleLabel:(NSString *)titleStr valueLabel:(NSString *)valueStr
{
    _m_titleLabel.text = titleStr;
    
    if (![valueStr length]) {
        CGRect valueFrame = _m_valueLabel.frame;
        valueFrame.size.height = 24;
        _m_valueLabel.frame = valueFrame;
        _m_valueLabel.textAlignment = NSTextAlignmentRight;
        _m_valueLabel.text = @"未填写";
        return;
    }
    
    CGFloat string_height = [valueStr getHeightWithFont:kCellTitleFont constrainedToSize:CGSizeMake(kValueLabelSizeWidth, MAXFLOAT)];
    if (string_height > 24) {
        CGRect valueFrame = _m_valueLabel.frame;
        valueFrame.size.height = string_height;
        _m_valueLabel.frame = valueFrame;
        _m_valueLabel.text = valueStr;
    }else{
        CGRect valueFrame = _m_valueLabel.frame;
        valueFrame.size.height = 24;
        _m_valueLabel.frame = valueFrame;
        _m_valueLabel.textAlignment = NSTextAlignmentRight;
        _m_valueLabel.text = valueStr;
    }
}

+ (CGFloat)cellHeightWith:(NSString *)string
{
    CGFloat string_height = [string getHeightWithFont:kCellTitleFont constrainedToSize:CGSizeMake(kValueLabelSizeWidth, MAXFLOAT)];
    if (string_height > 24) {
        return string_height+20;
    }else{
        return 44.0f;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
