//
//  TDImageTitleCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TDImageTitleCell.h"

@interface TDImageTitleCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_titleLabel;
@end

@implementation TDImageTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit_doc"]];
        
        [self.contentView addSubview:self.m_imageView];
        [self.contentView addSubview:self.m_titleLabel];
    }
    return self;
}

- (void)configWithTitleString:(NSString *)titleStr andStatus:(NSInteger)status {
    _m_titleLabel.text = titleStr;
    
    if (status == 1) {
        _m_imageView.image = [UIImage imageNamed:@"home_today_task"];
    }else {
        _m_imageView.image = [UIImage imageNamed:@"home_today_task_done"];
    }
}

+ (CGFloat)cellHeight {
    return 44.0f;
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
        UIImage *image = [UIImage imageNamed:@"home_today_task_done"];
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, ([TDImageTitleCell cellHeight] - image.size.height)/2.0, image.size.width, image.size.height)];
    }
    return _m_imageView;
}

- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_imageView.frame.origin.x + CGRectGetWidth(_m_imageView.bounds) + 10, ([TDImageTitleCell cellHeight] - 30)/2.0, kScreen_Width - _m_imageView.frame.origin.x - CGRectGetWidth(_m_imageView.bounds) - 2*10, 30)];
        _m_titleLabel.font = [UIFont systemFontOfSize:16];
        _m_titleLabel.textColor = [UIColor blackColor];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_titleLabel;
}

@end
