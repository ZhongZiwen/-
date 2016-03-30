//
//  TextValueCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TextValueCell.h"
#import "NSString+Common.h"

#define kPaddingLeftWidth 15
#define kTextFont       14
#define kValueFont      12
#define kTextColor      [UIColor blackColor]
#define kValueColor     [UIColor lightGrayColor]

@interface TextValueCell ()

@property (nonatomic, strong) UILabel *m_textLabel;
@property (nonatomic, strong) UILabel *m_valueLabel;
@end

@implementation TextValueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_textLabel];
        [self.contentView addSubview:self.m_valueLabel];
    }
    return self;
}

- (void)configWithTextString:(NSString *)textStr andValueString:(NSString *)valueStr {
    
    _m_textLabel.text = textStr;
    
    CGRect frame = _m_valueLabel.frame;
    
    if ([valueStr length]) {
        CGFloat height = [valueStr getHeightWithFont:[UIFont systemFontOfSize:kValueFont] constrainedToSize:CGSizeMake(kScreen_Width - 2 * kPaddingLeftWidth, MAXFLOAT)];
        if (height > 20) {
            frame.size.height = height;
        }else {
            frame.size.height = 20;
        }
        _m_valueLabel.frame = frame;
        _m_valueLabel.text = valueStr;
    }else {
        frame.size.height = 20;
        _m_valueLabel.frame = frame;
        _m_valueLabel.text = @"未填写";
    }
}

+ (CGFloat)cellHeightWithValueString:(NSString *)valueStr {
    CGFloat height = 50.0;
    if ([valueStr length]) {
        CGFloat h = [valueStr getHeightWithFont:[UIFont systemFontOfSize:kValueFont] constrainedToSize:CGSizeMake(kScreen_Width - 2 * kPaddingLeftWidth, MAXFLOAT)];
        if (height > 20) {
            height += h;
        }else {
            height += 20;
        }
    }else {
        height += 20;
    }
    return height;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UILabel*)m_textLabel {
    if (!_m_textLabel) {
        _m_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10, kScreen_Width - 2 * kPaddingLeftWidth, 20)];
        _m_textLabel.font = [UIFont systemFontOfSize:kTextFont];
        _m_textLabel.textColor = kTextColor;
        _m_textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_textLabel;
}

- (UILabel*)m_valueLabel {
    if (!_m_valueLabel) {
        _m_valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10+20+10, kScreen_Width - 2 * kPaddingLeftWidth, 0)];
        _m_valueLabel.font = [UIFont systemFontOfSize:kValueFont];
        _m_valueLabel.textColor = kValueColor;
        _m_valueLabel.textAlignment = NSTextAlignmentLeft;
        _m_valueLabel.numberOfLines = 0;
        _m_valueLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _m_valueLabel;
}

@end
