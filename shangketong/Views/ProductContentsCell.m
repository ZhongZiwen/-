//
//  ProductContentsCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ProductContentsCell.h"
#import "Product.h"

@interface ProductContentsCell ()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *countLabel;
@end

@implementation ProductContentsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.countLabel];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    Product *item = obj;
    
    _nameLabel.text = item.name;
    _countLabel.text = [NSString stringWithFormat:@"%@", item.child];
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

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:15];
        [_nameLabel setWidth:kScreen_Width - 15 - 64];
        [_nameLabel setHeight:[ProductContentsCell cellHeight]];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel*)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        [_countLabel setX:kScreen_Width - 44 - 30];
        [_countLabel setWidth:44];
        [_countLabel setHeight:[ProductContentsCell cellHeight]];
        _countLabel.font = [UIFont systemFontOfSize:14];
        _countLabel.textColor = [UIColor iOS7lightGrayColor];
        _countLabel.textAlignment = NSTextAlignmentRight;
    }
    return _countLabel;
}

@end
