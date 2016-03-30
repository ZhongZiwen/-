//
//  RegisterAccountListCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RegisterAccountListCell.h"
#import "NameIdModel.h"

@interface RegisterAccountListCell ()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel;
@end

@implementation RegisterAccountListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    NameIdModel *item = obj;
    
    _nameLabel.text = item.name;
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

- (UIImageView*)iconView {
    if (!_iconView) {
        UIImage *image = [UIImage imageNamed:@"tenant_icon"];
        _iconView = [[UIImageView alloc] initWithImage:image];
        [_iconView setWidth:image.size.width];
        [_iconView setHeight:image.size.height];
        [_iconView setX:15];
        [_iconView setCenterY:[RegisterAccountListCell cellHeight] / 2.0];
    }
    return _iconView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_nameLabel setWidth:kScreen_Width - CGRectGetMinX(_nameLabel.frame) - 30];
        [_nameLabel setHeight:20];
        [_nameLabel setCenterY:[RegisterAccountListCell cellHeight] / 2.0];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}
@end
