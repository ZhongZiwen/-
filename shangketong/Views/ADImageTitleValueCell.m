//
//  ADImageTitleValueCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ADImageTitleValueCell.h"

@interface ADImageTitleValueCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_titleLabel;
@property (nonatomic, strong) UILabel *m_valueLabel;
@end

@implementation ADImageTitleValueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self.contentView addSubview:self.m_imageView];
        [self.contentView addSubview:self.m_titleLabel];
        [self.contentView addSubview:self.m_valueLabel];
    }
    return self;
}

+ (CGFloat)cellHeight {
    return 50.0f;
}

- (void)configWithApprovalState:(NSInteger)state {
    _m_valueLabel.text = @"已通过";
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
        
        UIImage *image = [UIImage imageNamed:@"UMS_follow_on"];
        _m_imageView = [[UIImageView alloc] initWithImage:image];
        _m_imageView.frame = CGRectMake(10, ([ADImageTitleValueCell cellHeight]-image.size.height)/2.0, image.size.width, image.size.height);
    }
    return _m_imageView;
}

- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_imageView.frame.origin.x + CGRectGetWidth(_m_imageView.bounds) + 10, ([ADImageTitleValueCell cellHeight] - 20)/2.0, 100, 20)];
        _m_titleLabel.text = @"审批状态";
        _m_titleLabel.textColor = [UIColor blackColor];
        _m_titleLabel.font = [UIFont systemFontOfSize:14];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_titleLabel;
}

- (UILabel*)m_valueLabel {
    if (!_m_valueLabel) {
        _m_valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 30 - 100, _m_titleLabel.frame.origin.y, 100, 20)];
        _m_valueLabel.font = [UIFont systemFontOfSize:14];
        _m_valueLabel.textColor = [UIColor lightGrayColor];
        _m_valueLabel.textAlignment = NSTextAlignmentRight;
    }
    return _m_valueLabel;
}

@end
