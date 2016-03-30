//
//  DetailInfoSectionCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailInfoSectionCell.h"
#import "ColumnModel.h"

@interface DetailInfoSectionCell ()

@property (strong, nonatomic) UILabel *m_title;
@end

@implementation DetailInfoSectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"0xF8F8F8"];
        
        [self.contentView addSubview:self.m_title];
    }
    return self;
}

- (void)configWithModel:(ColumnModel *)model {
    _m_title.text = model.name;
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
- (UILabel*)m_title {
    if (!_m_title) {
        _m_title = [[UILabel alloc] init];
        [_m_title setX:15];
        [_m_title setWidth:kScreen_Width - 15 - 10];
        [_m_title setHeight:20];
        [_m_title setY:[DetailInfoSectionCell cellHeight] - CGRectGetHeight(_m_title.bounds) - 5];
        _m_title.font = [UIFont systemFontOfSize:14];
        _m_title.textAlignment = NSTextAlignmentLeft;
        _m_title.tintColor = [UIColor colorWithHexString:@"0x8b8c90"];
    }
    return _m_title;
}
@end
