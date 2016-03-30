//
//  InfoHeaderTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "InfoHeaderTableViewCell.h"

#define kImageViewSize 64

@interface InfoHeaderTableViewCell ()

@property (nonatomic, weak) UIImageView *m_headerView;
@property (nonatomic, weak) UILabel *m_titleLabel;
@property (nonatomic, weak) UILabel *m_detailLabel;
@end

@implementation InfoHeaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width-kCellLeftWidth-kImageViewSize, 10, kImageViewSize, kImageViewSize)];
        [self.contentView addSubview:headerView];
        _m_headerView = headerView;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellLeftWidth, 15, kScreen_Width-3*kCellLeftWidth-kImageViewSize, 34)];
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _m_titleLabel = titleLabel;
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellLeftWidth, 15+34, CGRectGetWidth(_m_titleLabel.bounds), 20)];
        detailLabel.font = [UIFont systemFontOfSize:14];
        detailLabel.textColor = [UIColor lightGrayColor];
        detailLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:detailLabel];
        _m_detailLabel = detailLabel;
    }
    return self;
}

- (void)setImageView:(NSString *)imageStr titleLabel:(NSString *)titleStr detailLabel:(NSString *)detailStr
{
    [_m_headerView setImage:[UIImage imageNamed:imageStr]];
    _m_titleLabel.text = titleStr;
    _m_detailLabel.text = detailStr;
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
