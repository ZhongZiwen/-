//
//  MenuSettingCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MenuSettingCell.h"

@interface MenuSettingCell ()

@property (nonatomic, weak) UIImageView *m_imageView;
@property (nonatomic, weak) UILabel *m_titleLabel;


@end

@implementation MenuSettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellLeftWidth, 12, [MenuSettingCell cellHeight]-2*12, [MenuSettingCell cellHeight]-2*12)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellLeftWidth, 11, 31, 24)];
        
        [self.contentView addSubview:imageView];
        _m_imageView = imageView;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2*kCellLeftWidth+CGRectGetWidth(_m_imageView.bounds), 10, 200, [MenuSettingCell cellHeight]-2*10)];
        titleLabel.font = kCellTitleFont;
        titleLabel.textColor = kCellTitleColor;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _m_titleLabel = titleLabel;
        
        UISwitch *mSwitch = [[UISwitch alloc] init];
        mSwitch.frame = CGRectMake(kScreen_Width-15-CGRectGetWidth(mSwitch.bounds), ([MenuSettingCell cellHeight]-CGRectGetHeight(mSwitch.bounds))*0.5, 0, 0);
//        [mSwitch addTarget:self action:@selector(switchDidChange:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:mSwitch];
        _m_switch = mSwitch;
    }
    return self;
}



- (void)setImageView:(NSString *)imageStr titleLabel:(NSString *)titleStr switchValue:(BOOL)value
{
    [_m_imageView setImage:[UIImage imageNamed:imageStr]];
    _m_titleLabel.text = titleStr;
    _m_switch.on = value;
}

+ (CGFloat)cellHeight
{
    return 45.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
