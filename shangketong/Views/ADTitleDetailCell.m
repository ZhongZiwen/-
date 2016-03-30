//
//  ADTitleDetailCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ADTitleDetailCell.h"

@interface ADTitleDetailCell ()

@property (nonatomic, strong) UILabel *m_titleLabel;
@property (nonatomic, strong) UILabel *m_detailLabel;
@end

@implementation ADTitleDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.m_titleLabel];
        [self.contentView addSubview:self.m_detailLabel];
    }
    return self;
}

- (void)configWithTitleString:(NSString *)titleStr andDetailString:(NSString *)detailStr {
    self.m_titleLabel.text = titleStr;
    self.m_detailLabel.text = detailStr;
}

+ (CGFloat)cellHeight {
    return 64.0f;
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
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, kScreen_Width-20, 22)];
        _m_titleLabel.font = [UIFont systemFontOfSize:14];
        _m_titleLabel.textColor = [UIColor blackColor];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_titleLabel;
}

- (UILabel*)m_detailLabel {
    if (!_m_detailLabel) {
        _m_detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_titleLabel.frame.origin.x, _m_titleLabel.frame.origin.y + CGRectGetHeight(_m_titleLabel.bounds), CGRectGetWidth(_m_titleLabel.bounds), 20)];
        _m_detailLabel.font = [UIFont systemFontOfSize:12];
        _m_detailLabel.textColor = [UIColor lightGrayColor];
        _m_detailLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_detailLabel;
}

@end
