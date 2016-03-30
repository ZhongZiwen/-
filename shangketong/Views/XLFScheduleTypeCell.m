//
//  XLFScheduleTypeCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFScheduleTypeCell.h"

@interface XLFScheduleTypeCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_textLabel;
@end

@implementation XLFScheduleTypeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_imageView];
        [self.contentView addSubview:self.m_textLabel];
    }
    return self;
}

- (void)configWithImageName:(UIImage *)image andText:(NSString *)text {
    _m_imageView.image = image;
    _m_textLabel.text = text;
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
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, ([XLFScheduleTypeCell cellHeight]-8)/2.0, 8, 8)];
        _m_imageView.contentMode = UIViewContentModeScaleAspectFill;
        _m_imageView.clipsToBounds = YES;
        _m_imageView.layer.cornerRadius = _m_imageView.frame.size.height/2;
    }
    return _m_imageView;
}

- (UILabel*)m_textLabel {
    if (!_m_textLabel) {
        _m_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + 8 + 10, 0, 200, [XLFScheduleTypeCell cellHeight])];
        _m_textLabel.font = [UIFont systemFontOfSize:14];
        _m_textLabel.textColor = [UIColor blackColor];
        _m_textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_textLabel;
}

@end
