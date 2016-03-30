//
//  TodayHeaderView.m
//  shangketong
//
//  Created by 蒋 on 16/1/14.
//  Copyright (c) 2016年 sungoin. All rights reserved.
//

#import "TodayHeaderView.h"

#define kHeaderImageViewHigth 64 //头像
#define kBgImageViewHigth 80

#define kLeftSpeacWidth 15 //左边距
#define KTopWpeacHight 10
#define kLabelWidth 200
@implementation TodayHeaderView

- (UIImageView *)bgView {
    if (!_bgView) {
        _bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kLeftSpeacWidth, kScreen_Width, kBgImageViewHigth)];
        [self addSubview:_bgView];
    }
    return _bgView;
}
- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftSpeacWidth, 8, kHeaderImageViewHigth, kHeaderImageViewHigth)];
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.layer.contentsScale = 10;
        _headerImageView.layer.cornerRadius = 6;
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_bgView addSubview:_headerImageView];
    }
    return _headerImageView;
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftSpeacWidth *2 + kHeaderImageViewHigth, KTopWpeacHight + 7, kLabelWidth, KTopWpeacHight * 2)];
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.textColor = [UIColor colorWithHexString:@"333333"];
        [_bgView addSubview:_nameLabel];
    }
    return _nameLabel;
}
- (UILabel *)companyLabel {
    if (!_companyLabel) {
        _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftSpeacWidth *2 + kHeaderImageViewHigth, KTopWpeacHight * 3 + 13 , kScreen_Width-130, KTopWpeacHight *2)];
        _companyLabel.font = [UIFont systemFontOfSize:14];
        _companyLabel.textColor = [UIColor colorWithHexString:@"7a8c99"];
        [_bgView addSubview:_companyLabel];
    }
    return _companyLabel;
}
- (UIImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width - kLeftSpeacWidth - 8, (80 - 13) / 2, 8, 13)];
        [_bgView addSubview:_rightImageView];
    }
    return _rightImageView;
}
@end
