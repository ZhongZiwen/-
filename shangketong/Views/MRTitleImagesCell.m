//
//  MRTitleImagesCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MRTitleImagesCell.h"

@interface MRTitleImagesCell ()

@property (nonatomic, strong) UILabel *m_titleLabel;
@property (nonatomic, strong) UIView *m_iViewBGView;
@end

@implementation MRTitleImagesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit_doc"]];
        
        [self.contentView addSubview:self.m_titleLabel];
        [self.contentView addSubview:self.m_iViewBGView];
    }
    return self;
}

- (void)configWithTitleString:(NSString *)titleStr andObject:(id)obj andType:(DataSourceType)type {
    _m_titleLabel.text = titleStr;
    
    for (UIView *view in _m_iViewBGView.subviews) {
        [view removeFromSuperview];
    }
    
    if (type == DataSourceTypeDictionary) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_icon_default_90"]];
        imageView.frame = CGRectMake(0, 0, 30, 30);
        [_m_iViewBGView addSubview:imageView];
    }else {
        for (int i = 0; i < ((NSArray*)obj).count; i ++) {
            NSDictionary *dict = ((NSArray*)obj)[i];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_icon_default_90"]];
            imageView.frame = CGRectMake((30 + 10)*(i%7), (30+10)*(i/7), 30, 30);
            [_m_iViewBGView addSubview:imageView];
        }
    }
}

#warning 根据成员个数动态取cell高度(现在模拟只有一行成员)
+ (CGFloat)cellHeightWithType:(DataSourceType)type andMembersCount:(NSInteger)count {
    return 80.0f;
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
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 150, 20)];
        _m_titleLabel.tag = 100;
        _m_titleLabel.font = [UIFont systemFontOfSize:14];
        _m_titleLabel.textColor = kTitleColor;
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_titleLabel;
}

- (UIView*)m_iViewBGView {
    if (!_m_iViewBGView) {
        _m_iViewBGView = [[UIView alloc] initWithFrame:CGRectMake(15, 40, kScreen_Width - 30, 0)];
        _m_iViewBGView.backgroundColor = [UIColor clearColor];
    }
    return _m_iViewBGView;
}

@end
