//
//  ExportAddressTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ExportAddressTableViewCell.h"
#import "AddressBook.h"
#import <UIImageView+WebCache.h>

@interface ExportAddressTableViewCell ()

@property (nonatomic, weak) UIImageView *m_headView;
@property (nonatomic, weak) UILabel *m_nameLabel;
@property (nonatomic, weak) UILabel *m_departLabel;
@end

@implementation ExportAddressTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellLeftWidth, 10, [ExportAddressTableViewCell cellHeight]-2*10, [ExportAddressTableViewCell cellHeight]-2*10)];
        headView.contentMode = UIViewContentModeScaleAspectFill;
        headView.layer.cornerRadius = 5;
        headView.clipsToBounds = YES;
        [self.contentView addSubview:headView];
        _m_headView = headView;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        [nameLabel setX:CGRectGetMaxX(_m_headView.frame) + kCellLeftWidth];
        [nameLabel setY:CGRectGetMinY(_m_headView.frame)];
        [nameLabel setWidth:kScreen_Width - CGRectGetMinX(nameLabel.frame) - 40];
        [nameLabel setHeight:24];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = kCellTitleColor;
        nameLabel.font = kCellTitleFont;
        [self.contentView addSubview:nameLabel];
        _m_nameLabel = nameLabel;
        
        UILabel *departLabel = [[UILabel alloc] init];
        [departLabel setX:CGRectGetMinX(_m_nameLabel.frame)];
        [departLabel setY:CGRectGetMaxY(_m_nameLabel.frame)];
        [departLabel setWidth:CGRectGetWidth(_m_nameLabel.bounds)];
        [departLabel setHeight:20];
        departLabel.textAlignment = NSTextAlignmentLeft;
        departLabel.textColor = [UIColor lightGrayColor];
        departLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:departLabel];
        _m_departLabel = departLabel;
    }
    return self;
}

- (void)configWithModel:(AddressBook *)model
{
    [_m_headView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    
    _m_nameLabel.text = model.name;
    
    if (model.position) {
        _m_departLabel.text = [NSString stringWithFormat:@"%@ | %@", model.depart, model.position];
    }else {
        _m_departLabel.text = model.depart;
    }
}

+ (CGFloat)cellHeight
{
    return 64.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
