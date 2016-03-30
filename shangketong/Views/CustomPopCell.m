//
//  CustomPopCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomPopCell.h"
#import "NSString+Common.h"
#import "UIView+Common.h"

@interface CustomPopCell ()

@property (nonatomic, strong) UILabel *m_titleLabel;
@property (nonatomic, strong) UIImageView *m_imageView;
@end

@implementation CustomPopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0f];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        NSLog(@"cellWidth = %f cellSuperWidth = %f", CGRectGetWidth(self.bounds), CGRectGetWidth(self.contentView.bounds));
        [self.contentView addSubview:self.m_titleLabel];
        [self.contentView addSubview:self.m_imageView];
    }
    return self;
}

- (void)configWithTitle:(NSString *)title andImageName:(NSString *)imageName {
    
    [_m_titleLabel setWidth:[title getWidthWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAXFLOAT, 20)]];
    _m_titleLabel.text = title;
    
    if (imageName && imageName.length > 0) {
        _m_imageView.hidden = NO;
        _m_imageView.image = [UIImage imageNamed:imageName];
    }else {
        _m_imageView.hidden = YES;
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

- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 0, CGRectGetHeight(self.bounds))];
        _m_titleLabel.font = [UIFont systemFontOfSize:14];
        _m_titleLabel.textColor = [UIColor whiteColor];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    return _m_titleLabel;
}

- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - 35, ([CustomPopCell cellHeight] - 20) / 2.0, 20, 20)];
    }
    return _m_imageView;
}

@end
