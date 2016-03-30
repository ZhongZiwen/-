//
//  MeHeaderTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MeHeaderTableViewCell.h"
#import "CommonConstant.h"
#import "UIImageView+WebCache.h"

@interface MeHeaderTableViewCell ()

@property (nonatomic, weak) UIImageView *m_headerView;
@property (nonatomic, weak) UILabel *m_nameLabel;
@property (nonatomic, weak) UILabel *m_companyLabel;
@end

@implementation MeHeaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellLeftWidth, 10, 64, 64)];
        headerView.contentMode = UIViewContentModeScaleAspectFill;
        headerView.clipsToBounds = YES;
        [self.contentView addSubview:headerView];
        _m_headerView = headerView;
        _m_headerView.layer.masksToBounds = YES;
        _m_headerView.layer.cornerRadius = 5;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2*kCellLeftWidth+CGRectGetWidth(_m_headerView.bounds), 10, kScreen_Width-3*kCellLeftWidth-CGRectGetWidth(_m_headerView.bounds), 32)];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:nameLabel];
        _m_nameLabel = nameLabel;
        
        UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_nameLabel.frame.origin.x, 10+CGRectGetHeight(_m_nameLabel.bounds), CGRectGetWidth(_m_nameLabel.bounds), 32)];
        companyLabel.textAlignment = NSTextAlignmentLeft;
        companyLabel.font = [UIFont systemFontOfSize:16];
        companyLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:companyLabel];
        _m_companyLabel = companyLabel;
    }
    return self;
}

- (void)setImageView:(NSString *)imageStr titleLabel:(NSString *)titleStr detailLabel:(NSString *)detailStr
{
//    [_m_headerView setImage:[UIImage imageNamed:imageStr]];
    [_m_headerView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
    
    _m_nameLabel.text = titleStr;
    _m_companyLabel.text = detailStr;
}

+ (CGFloat)cellHeight
{
    return 84.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
