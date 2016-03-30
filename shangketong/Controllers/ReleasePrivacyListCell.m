//
//  ReleasePrivacyListCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ReleasePrivacyListCell.h"
#import <UIImageView+WebCache.h>

@interface ReleasePrivacyListCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_titleLabel;
@end

@implementation ReleasePrivacyListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_imageView];
        [self.contentView addSubview:self.m_titleLabel];
    }
    return self;
}

- (void)configWithImageName:(NSString *)imageName andTitle:(NSString *)title  andCount:(NSInteger) count{
//    [_m_imageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    _m_imageView.image = [UIImage imageNamed:imageName];
    
    if (count > 0) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%ti)", title, count]];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(title.length, [str length] - title.length)];
        _m_titleLabel.attributedText = str;
    }else{
        _m_titleLabel.text = title;
    }
    
}

+ (CGFloat)cellHeight {
    return 64.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 44, 44)];
        _m_imageView.layer.cornerRadius = 5;
        _m_imageView.clipsToBounds = YES;
        
    }
    return _m_imageView;
}

- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(74, 10, kScreen_Width - 74 - 15, 44)];
        _m_titleLabel.font = [UIFont systemFontOfSize:16];
        _m_titleLabel.textColor = [UIColor blackColor];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_titleLabel;
}
@end
