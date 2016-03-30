//
//  ActivityRecordPositionView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordPositionView.h"

@interface ActivityRecordPositionView ()

@property (strong, nonatomic) UIButton *bgView;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@end

@implementation ActivityRecordPositionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"lbsmap"];
        [self setHeight:image.size.height + 10];
        
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor iOS7lightGrayColor].CGColor;
        
        [self addSubview:self.bgView];
        [self addSubview:self.iconView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.detailLabel];
    }
    return self;
}

- (void)configWithTitle:(NSString *)title detail:(NSString *)detail {
    _titleLabel.text = title;
    _detailLabel.text = detail;
}

- (UIButton*)bgView {
    if (!_bgView) {
        _bgView = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgView.frame = self.bounds;
        [_bgView addTarget:self action:@selector(bgButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgView;
}

- (UIImageView*)iconView {
    if (!_iconView) {
        UIImage *image = [UIImage imageNamed:@"lbsmap"];
        _iconView = [[UIImageView alloc] initWithImage:image];
        [_iconView setX:5];
        [_iconView setWidth:image.size.width];
        [_iconView setHeight:image.size.height];
        [_iconView setCenterY:CGRectGetHeight(self.bounds) / 2.0];
    }
    return _iconView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_titleLabel setY:CGRectGetMinY(_iconView.frame)];
        [_titleLabel setWidth:CGRectGetWidth(self.bounds) - CGRectGetMinX(_titleLabel.frame) - 15];
        [_titleLabel setHeight:CGRectGetHeight(_iconView.bounds) * 3 / 5.0];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_detailLabel setY:CGRectGetMaxY(_titleLabel.frame)];
        [_detailLabel setWidth:CGRectGetWidth(self.bounds) - CGRectGetMinX(_titleLabel.frame) - 15];
        [_detailLabel setHeight:CGRectGetHeight(_iconView.bounds) * 2 / 5.0];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.textColor = [UIColor iOS7lightGrayColor];
    }
    return _detailLabel;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
