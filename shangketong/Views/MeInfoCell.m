//
//  MeInfoCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MeInfoCell.h"
#import "UIView+Common.h"
#import "NSString+Common.h"

#define kTitleFont [UIFont systemFontOfSize:14]
#define kDetailFont [UIFont systemFontOfSize:14]

@interface MeInfoCell ()

@property (nonatomic, strong) UILabel *m_titleLabel;
@property (nonatomic, strong) UILabel *m_detailLabel;
@property (nonatomic, strong) UIImageView *m_lineImageView;
@end

@implementation MeInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        [self.contentView addSubview:self.m_lineImageView];
        [self.contentView addSubview:self.m_titleLabel];
        [self.contentView addSubview:self.m_detailLabel];
    }
    return self;
}

- (void)configWithTitleString:(NSString *)titleStr andDetailString:(NSString *)detailStr {
    _m_titleLabel.text = titleStr;
    
    CGFloat height = [detailStr getHeightWithFont:kDetailFont constrainedToSize:CGSizeMake(kScreen_Width - 20, MAXFLOAT)];
    if (height < 20) {
        [_m_detailLabel setHeight:20];
    }
    else {
        [_m_detailLabel setHeight:height];
    }
    
    if (detailStr && [detailStr length]) {
        _m_detailLabel.text = detailStr;
    }
    else {
        _m_detailLabel.text = @"未填写";
    }
}

+ (CGFloat)cellHeightWith:(NSString *)string {
    CGFloat height = [string getHeightWithFont:kDetailFont constrainedToSize:CGSizeMake(kScreen_Width - 20, MAXFLOAT)];
    if (height < 20) {
        return 64;
    }
    else {
        return 44 + height;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIImageView*)m_lineImageView {
    if (!_m_lineImageView) {
        _m_lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width , 1)];
        _m_lineImageView.image = [UIImage imageNamed:@"line.png"];
    }
    return _m_lineImageView;
}

- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, kScreen_Width - 20, 20)];
        _m_titleLabel.font = kTitleFont;
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
        _m_titleLabel.textColor = [UIColor lightGrayColor];
    }
    return _m_titleLabel;
}

- (UILabel*)m_detailLabel {
    if (!_m_detailLabel) {
        _m_detailLabel = [[UILabel alloc] init];
        [_m_detailLabel setX:CGRectGetMinX(_m_titleLabel.frame)];
        [_m_detailLabel setY:CGRectGetMaxY(_m_titleLabel.frame) + 4];
        [_m_detailLabel setWidth:CGRectGetWidth(_m_titleLabel.bounds)];
        [_m_detailLabel setHeight:20];
        _m_detailLabel.font = kDetailFont;
        _m_detailLabel.textAlignment = NSTextAlignmentLeft;
        _m_detailLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
        _m_detailLabel.numberOfLines = 0;
        _m_detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _m_detailLabel;
}

@end
