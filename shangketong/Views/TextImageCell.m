//
//  TextImageCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TextImageCell.h"
#define kPaddingLeftWidth   15
#define kTextFont           14
#define kTextColor          [UIColor blackColor]

@interface TextImageCell ()

@property (nonatomic, strong) UILabel *m_textLabel;
@property (nonatomic, strong) UIImageView *m_imageView;
@end

@implementation TextImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_textLabel];
        [self.contentView addSubview:self.m_imageView];
    }
    return self;
}

- (void)configWithText:(NSString *)textStr andImage:(UIImage *)image {
    _m_textLabel.text = textStr;
    _m_imageView.image = image;
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
- (UILabel*)m_textLabel {
    if (!_m_textLabel) {
        _m_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([TextImageCell cellHeight] - 30)/2.0, 150, 30)];
        _m_textLabel.font = [UIFont systemFontOfSize:kTextFont];
        _m_textLabel.textColor = kTextColor;
        _m_textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_textLabel;
}

- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width - 30 - 40, 2, 40, 40)];
        _m_imageView.contentMode = UIViewContentModeScaleAspectFill;
        _m_imageView.clipsToBounds = YES;
    }
    return _m_imageView;
}

@end
