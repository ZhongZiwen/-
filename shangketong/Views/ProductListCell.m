//
//  ProductListCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ProductListCell.h"
#import "Product.h"

@interface ProductListCell ()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *totalPriceLabel;
@end

@implementation ProductListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.priceLabel];
        [self.contentView addSubview:self.totalPriceLabel];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    Product *item = obj;
    [_iconView sd_setImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:[UIImage imageNamed:@"product_icon_default"]];
    _nameLabel.text = item.name;
    _priceLabel.text = [NSString stringWithFormat:@"价格：%@元  x%@", item.unitPrice, item.number];
    _totalPriceLabel.text = [NSString stringWithFormat:@"金额：%@元", item.totalPrivce];
}

+ (CGFloat)cellHeight {
    return 70.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - event response
- (UIImageView*)iconView {
    if (!_iconView) {
        
        UIImage *image = [UIImage imageNamed:@"product_icon_default"];
        _iconView = [[UIImageView alloc] init];
        [_iconView setX:15];
        [_iconView setY:5];
        [_iconView setWidth:image.size.width];
        [_iconView setHeight:image.size.height];
    }
    return _iconView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_nameLabel setY:CGRectGetMinY(_iconView.frame)];
        [_nameLabel setWidth:kScreen_Width - CGRectGetMinX(_nameLabel.frame) - 15];
        [_nameLabel setHeight:20];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel*)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        [_priceLabel setX:CGRectGetMinX(_nameLabel.frame)];
        [_priceLabel setY:CGRectGetMaxY(_nameLabel.frame)];
        [_priceLabel setWidth:CGRectGetWidth(_nameLabel.bounds)];
        [_priceLabel setHeight:20];
        _priceLabel.font = [UIFont systemFontOfSize:13];
        _priceLabel.textColor = [UIColor iOS7darkGrayColor];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _priceLabel;
}

- (UILabel*)totalPriceLabel {
    if (!_totalPriceLabel) {
        _totalPriceLabel = [[UILabel alloc] init];
        [_totalPriceLabel setX:CGRectGetMinX(_nameLabel.frame)];
        [_totalPriceLabel setY:CGRectGetMaxY(_priceLabel.frame)];
        [_totalPriceLabel setWidth:CGRectGetWidth(_nameLabel.bounds)];
        [_totalPriceLabel setHeight:20];
        _totalPriceLabel.font = [UIFont systemFontOfSize:14];
        _totalPriceLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _totalPriceLabel;
}

@end
