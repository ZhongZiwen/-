//
//  SearchSectionCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SearchSectionCell.h"

@interface SearchSectionCell ()

@property (strong, nonatomic) UILabel *sectionLabel;
@end

@implementation SearchSectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        [self.contentView addSubview:self.sectionLabel];
    }
    return self;
}

- (void)configWithTitle:(NSString *)string {
    _sectionLabel.text = string;
}

+ (CGFloat)cellHeight {
    return 30;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel*)sectionLabel {
    if (!_sectionLabel) {
        _sectionLabel = [[UILabel alloc] init];
        [_sectionLabel setX:15];
        [_sectionLabel setWidth:kScreen_Width - 15 * 2];
        [_sectionLabel setHeight:[SearchSectionCell cellHeight]];
        _sectionLabel.font = [UIFont systemFontOfSize:12];
        _sectionLabel.textColor = [UIColor iOS7lightGrayColor];
    }
    return _sectionLabel;
}
@end
