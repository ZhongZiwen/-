//
//  ADImageTitleCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ADImageTitleCell.h"
#import "NSString+Common.h"

@interface ADImageTitleCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_contentLabel;
@end

@implementation ADImageTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.m_imageView];
        [self.contentView addSubview:self.m_contentLabel];
    }
    return self;
}

+ (CGFloat)cellHeight {
    return 44.0f;
}

- (void)configWithApprovalTime:(NSString *)timeStr andResult:(NSInteger)result {
    NSString *time = [NSString msgRemindApprovalTransDateWithTimeInterval:timeStr];
    _m_contentLabel.text = [NSString stringWithFormat:@"%@ 我%@了此申请", time, (result? @"同意":@"拒绝")];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setters and Getters
- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        UIImage *image = [UIImage imageNamed:@"tab_recent_normal"];
        _m_imageView = [[UIImageView alloc] initWithImage:image];
        _m_imageView.frame = CGRectMake(10, ([ADImageTitleCell cellHeight] - image.size.height)/2.0, image.size.width, image.size.height);
    }
    return _m_imageView;
}

- (UILabel*)m_contentLabel {
    if (!_m_contentLabel) {
        _m_contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_imageView.frame.origin.x + CGRectGetWidth(_m_imageView.bounds) + 10, ([ADImageTitleCell cellHeight]-20)/2.0, kScreen_Width - _m_imageView.frame.origin.x - CGRectGetWidth(_m_imageView.bounds) - 2*10, 20)];
        _m_contentLabel.font = [UIFont systemFontOfSize:14];
        _m_contentLabel.textColor = [UIColor lightGrayColor];
        _m_contentLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_contentLabel;
}

@end
