//
//  PoolReturnPoolCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PoolReturnPoolCell.h"

@interface PoolReturnPoolCell ()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@end

@implementation PoolReturnPoolCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.bgView];
        [_bgView addSubview:self.titleLabel];
        [_bgView addSubview:self.detailLabel];
    }
    return self;
}

- (void)configWithString:(NSString *)str {
    if (str) {
        _detailLabel.textColor = [UIColor blackColor];
        _detailLabel.text = str;
        return;
    }
    
    _detailLabel.text = @"请选择公海池";
    _detailLabel.textColor = [UIColor iOS7lightGrayColor];
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

- (UIView*)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        [_bgView setX:15];
        [_bgView setY:0];
        [_bgView setWidth:kScreen_Width - 30];
        [_bgView setHeight:44.0f];
        _bgView.layer.cornerRadius = 5;
        _bgView.layer.borderWidth = 0.5;
        _bgView.layer.borderColor = [UIColor iOS7lightGrayColor].CGColor;
    }
    return _bgView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setX:10];
        [_titleLabel setWidth:60];
        [_titleLabel setHeight:30];
        [_titleLabel setCenterY:CGRectGetHeight(_bgView.bounds) / 2];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.text = @"退回到";
    }
    return _titleLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setX:CGRectGetMaxX(_titleLabel.frame)];
        [_detailLabel setWidth:CGRectGetWidth(_bgView.bounds) - CGRectGetMinX(_detailLabel.frame) - 15];
        [_detailLabel setHeight:30];
        [_detailLabel setCenterY:CGRectGetHeight(_bgView.bounds) / 2];
        _detailLabel.font = [UIFont systemFontOfSize:16];
        _detailLabel.textAlignment = NSTextAlignmentRight;
    }
    return _detailLabel;
}

@end
