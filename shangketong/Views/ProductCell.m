//
//  ProductCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ProductCell.h"
#import "Product.h"

@interface ProductCell ()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@end

@implementation ProductCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.priceLabel];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    Product *item = obj;
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:[UIImage imageNamed:@"product_icon_default"]];
    _nameLabel.text = item.name;
    _priceLabel.text = [NSString stringWithFormat:@"价格: %@元/%@", [self.numberFormatter stringFromNumber:item.price], item.unit];
}

+ (CGFloat)cellHeight {
    return 54.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (UIImageView*)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        [_iconView setX:15];
        [_iconView setY:10];
        [_iconView setWidth:[ProductCell cellHeight] - 2 * 10];
        [_iconView setHeight:[ProductCell cellHeight] - 2 * 10];
    }
    return _iconView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_nameLabel setY:CGRectGetMinY(_iconView.frame)];
        [_nameLabel setWidth:kScreen_Width - CGRectGetMinX(_nameLabel.frame) - 15];
        [_nameLabel setHeight:CGRectGetHeight(_iconView.bounds) * 3 / 5.0];
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
        [_priceLabel setHeight:CGRectGetHeight(_iconView.bounds) * 2 / 5.0];
        _priceLabel.font = [UIFont systemFontOfSize:13];
        _priceLabel.textColor = [UIColor iOS7lightGrayColor];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _priceLabel;
}

- (NSNumberFormatter*)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    }
    return _numberFormatter;
}

@end
