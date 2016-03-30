//
//  TitleImageCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TitleImageCell.h"

@interface TitleImageCell ()

@property (nonatomic, weak) UIImageView *m_imageView;
@property (nonatomic, weak) UILabel *m_titleLabel;
@end

@implementation TitleImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellLeftWidth, 12, [TitleImageCell cellHeight]-2*12, [TitleImageCell cellHeight]-2*12)];
        [self.contentView addSubview:imageView];
        _m_imageView = imageView;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2*kCellLeftWidth+CGRectGetWidth(_m_imageView.bounds), 10, 200, [TitleImageCell cellHeight]-2*10)];
        titleLabel.font = kCellTitleFont;
        titleLabel.textColor = kCellTitleColor;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _m_titleLabel = titleLabel;
    }
    return self;
}

- (void)setImageView:(NSString *)imageStr titleLabel:(NSString *)titleStr
{
    [_m_imageView setImage:[UIImage imageNamed:imageStr]];
    [_m_titleLabel setText:titleStr];
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
