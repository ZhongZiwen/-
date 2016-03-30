//
//  EditHeaderTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EditHeaderTableViewCell.h"
#import "CommonConstant.h"
#import "UIImageView+WebCache.h"

#define kTitleLabelSizeWidth 70
#define kImageViewSize 64

@interface EditHeaderTableViewCell ()

@property (nonatomic, weak) UILabel *m_titleLabel;
@property (nonatomic, weak) UIImageView *m_imageView;
@end

@implementation EditHeaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellLeftWidth, ([EditHeaderTableViewCell cellHeight]-24)/2.0, kTitleLabelSizeWidth, 24)];
        titleLabel.font = kCellTitleFont;
        titleLabel.textColor = kCellTitleColor;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _m_titleLabel = titleLabel;
        
        UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width-kImageViewSize-30, 10, kImageViewSize, kImageViewSize)];
        headerView.contentMode = UIViewContentModeScaleAspectFill;
        headerView.clipsToBounds = YES;
        headerView.layer.cornerRadius = headerView.frame.size.height/2;
        [self.contentView addSubview:headerView];
        _m_imageView = headerView;
    }
    return self;
}

- (void)setTitleLabel:(NSString *)titleStr headerImageView:(UIImage *)image
{
    _m_titleLabel.text = titleStr;
    _m_imageView.image = image;
//    [_m_imageView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
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
