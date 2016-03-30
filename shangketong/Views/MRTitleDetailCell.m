//
//  MRTitleDetailCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MRTitleDetailCell.h"
#import "NSString+Common.h"

@interface MRTitleDetailCell ()

@property (nonatomic, strong) UILabel *m_titleLabel;
@property (nonatomic, strong) UILabel *m_detailLabel;
@end

@implementation MRTitleDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_titleLabel];
        [self.contentView addSubview:self.m_detailLabel];
    }
    return self;
}

- (void)configWithTitleString:(NSString *)titleStr andDetailString:(NSString *)detailStr {
    _m_titleLabel.text = titleStr;
    
    CGRect frame = _m_detailLabel.frame;
    
    if ([detailStr length]) {
        CGFloat height = [detailStr getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, MAXFLOAT)];
        if (height > 20) {
            frame.size.height = height;
        }else {
            frame.size.height = 20;
        }
        _m_detailLabel.frame = frame;
        _m_detailLabel.text = detailStr;
    }else {
        frame.size.height = 20;
        _m_detailLabel.frame = frame;
        _m_detailLabel.text = @"未填写";
    }
}

+ (CGFloat)cellHeightWithDetailString:(NSString *)detailStr {
    CGFloat height = 50.0;
    if ([detailStr length]) {
        CGFloat h = [detailStr getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, MAXFLOAT)];
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
- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 150, 20)];
        _m_titleLabel.font = [UIFont systemFontOfSize:14];
        _m_titleLabel.textColor = kTitleColor;
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_titleLabel;
}

- (UILabel*)m_detailLabel {
    if (!_m_detailLabel) {
        _m_detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10+20+10, kScreen_Width - 30, 0)];
        _m_detailLabel.font = [UIFont systemFontOfSize:14];
        _m_detailLabel.textColor = [UIColor blackColor];
        _m_detailLabel.textAlignment = NSTextAlignmentLeft;
        _m_detailLabel.numberOfLines = 0;
        _m_detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _m_detailLabel;
}

@end
