//
//  CustomActionSheetCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomActionSheetCell.h"

@interface CustomActionSheetCell ()

@property (nonatomic, strong) UILabel *m_titleLabel;
@end

@implementation CustomActionSheetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_titleLabel];
    }
    return self;
}

- (void)configWithString:(NSString *)string {
    if ([string isEqualToString:@"删除该市场活动"] || [string isEqualToString:@"废弃"]) {
        _m_titleLabel.textColor = [UIColor iOS7redColor];
    }else {
        _m_titleLabel.textColor = [UIColor blackColor];
    }
    _m_titleLabel.text = string;
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
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 48)];
        _m_titleLabel.font = [UIFont systemFontOfSize:16];
        _m_titleLabel.textAlignment = NSTextAlignmentCenter;
        _m_titleLabel.textColor = [UIColor blackColor];
    }
    return _m_titleLabel;
}

@end
