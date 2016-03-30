//
//  NavDropAssetLibCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "NavDropAssetLibCell.h"

@interface NavDropAssetLibCell ()

@property (nonatomic, strong) UIImageView *mImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation NavDropAssetLibCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.mImageView];

        [self.contentView addSubview:self.titleLabel];

        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

+ (CGFloat)cellHeight {
    return 64.0f;
}

- (void)configImageView:(UIImage *)image Title:(NSString *)title andDetail:(NSString *)detail {
    
    _mImageView.image = image;
    _titleLabel.text = title;
    _detailLabel.text = detail;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIImageView*)mImageView {
    if (!_mImageView) {
        _mImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, ([NavDropAssetLibCell cellHeight]-54)/2.0, 54, 54)];
    }
    return _mImageView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_mImageView.frame.origin.x+CGRectGetWidth(_mImageView.bounds)+15, _mImageView.frame.origin.y, 200, 34)];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y+CGRectGetHeight(_titleLabel.bounds), 200, 20)];
        _detailLabel.textColor = [UIColor lightGrayColor];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _detailLabel;
}

@end
