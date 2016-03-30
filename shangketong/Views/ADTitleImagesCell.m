//
//  ADTitleImagesCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ADTitleImagesCell.h"

@interface ADTitleImagesCell ()

@property (nonatomic, strong) UILabel *m_titleLabel;
@end

@implementation ADTitleImagesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_titleLabel];
    }
    return self;
}

+ (CGFloat)cellHeightWithCopysCount:(NSInteger)count {
    return 64.0f;
}

- (void)configWithCopysArray:(NSArray *)copys {
    
    UIImageView *iView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_icon_default_90"]];
    iView.frame = CGRectMake(_m_titleLabel.frame.origin.x, _m_titleLabel.frame.origin.y + CGRectGetHeight(_m_titleLabel.bounds), 30, 30);
    [self.contentView addSubview:iView];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 22)];
        _m_titleLabel.font = [UIFont systemFontOfSize:14];
        _m_titleLabel.textColor = [UIColor blackColor];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
        _m_titleLabel.text = @"抄送人";
    }
    return _m_titleLabel;
}

@end
