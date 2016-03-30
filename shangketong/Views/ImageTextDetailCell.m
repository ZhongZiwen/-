//
//  ImageTextDetailCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ImageTextDetailCell.h"

#define kPaddingLeftWidth 15
#define kTextFont       14
#define kDetailFont     12
#define kTextColor      [UIColor blackColor]
#define kDetailColor    [UIColor lightGrayColor]

@interface ImageTextDetailCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_textLabel;
@property (nonatomic, strong) UILabel *m_detailLabel;
@end

@implementation ImageTextDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.contentView addSubview:self.m_imageView];
        [self.contentView addSubview:self.m_textLabel];
        [self.contentView addSubview:self.m_detailLabel];
    }
    return self;
}

- (void)configWithImageString:(NSString *)imageStr andText:(NSString *)textStr andDetail:(NSString *)detailStr {
    UIImage *image = [UIImage imageNamed:imageStr];
    
    CGRect frame = _m_imageView.frame;
    frame.origin.x = kPaddingLeftWidth;
    frame.origin.y = ([ImageTextDetailCell cellHeight]-image.size.height)/2.0;
    frame.size.width = image.size.width;
    frame.size.height = image.size.height;
    _m_imageView.frame = frame;
    _m_imageView.image = image;
    
    frame = _m_textLabel.frame;
    frame.origin.x = kPaddingLeftWidth + image.size.width + 10;
    frame.origin.y = ([ImageTextDetailCell cellHeight]-30)/2.0;
    frame.size.width = 180;
    frame.size.height = 30;
    _m_textLabel.frame = frame;
    _m_textLabel.text = textStr;
    
    _m_detailLabel.text = detailStr;
}

+ (CGFloat)cellHeight {
    return 50.0f;
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
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];

    }
    return _m_imageView;
}

- (UILabel*)m_textLabel {
    if (!_m_textLabel) {
        _m_textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _m_textLabel.font = [UIFont systemFontOfSize:kTextFont];
        _m_textLabel.textColor = kTextColor;
        _m_textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_textLabel;
}

- (UILabel*)m_detailLabel {
    if (!_m_detailLabel) {
        _m_detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 30, ([ImageTextDetailCell cellHeight]-30)/2.0, 200, 30)];
        _m_detailLabel.font = [UIFont systemFontOfSize:kDetailFont];
        _m_detailLabel.textColor = kDetailColor;
        _m_detailLabel.textAlignment = NSTextAlignmentRight;
    }
    return _m_detailLabel;
}

@end
