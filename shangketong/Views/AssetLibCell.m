//
//  AssetLibCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AssetLibCell.h"

@interface AssetLibCell ()

@property (strong, nonatomic) UIImageView *m_imageView;
@property (strong, nonatomic) UILabel *m_titleLabel;
@property (strong, nonatomic) UILabel *m_detailLabel;
@end

@implementation AssetLibCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.m_imageView];
        [self.contentView addSubview:self.m_titleLabel];
        [self.contentView addSubview:self.m_detailLabel];
    }
    return self;
}

+ (CGFloat)cellHeight {
    return 64.0f;
}

- (void)configImageView:(UIImage *)image Title:(NSString *)title andDetail:(NSString *)detail {
    _m_imageView.image = image;
    _m_titleLabel.text = title;
    _m_detailLabel.text = detail;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] init];
        [_m_imageView setX:15];
        [_m_imageView setWidth:54];
        [_m_imageView setHeight:54];
        [_m_imageView setCenterY:[AssetLibCell cellHeight] / 2];
    }
    return _m_imageView;
}

- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabel alloc] init];
        [_m_titleLabel setX:CGRectGetMaxX(_m_imageView.frame) + 15];
        [_m_titleLabel setY:5];
        [_m_titleLabel setWidth:kScreen_Width - 10 - CGRectGetMinX(_m_titleLabel.frame)];
        [_m_titleLabel setHeight:34];
        _m_titleLabel.textColor = [UIColor blackColor];
        _m_titleLabel.font = [UIFont systemFontOfSize:18];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_titleLabel;
}

- (UILabel*)m_detailLabel {
    if (!_m_detailLabel) {
        _m_detailLabel = [[UILabel alloc] init];
        [_m_detailLabel setX:CGRectGetMaxX(_m_imageView.frame) + 15];
        [_m_detailLabel setY:5 + 34];
        [_m_detailLabel setWidth:CGRectGetWidth(_m_titleLabel.bounds)];
        [_m_detailLabel setHeight:20];
        _m_detailLabel.font = [UIFont systemFontOfSize:14];
        _m_detailLabel.textColor = [UIColor lightGrayColor];
        _m_detailLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_detailLabel;
}


@end
