//
//  ScheduleTypeCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ScheduleTypeCell.h"
#import "ScheduleType.h"

@interface ScheduleTypeCell ()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation ScheduleTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    ScheduleType *item = obj;
    
    _iconView.image = [UIImage imageWithColor:[UIColor colorWithColorType:item.color]];
    _titleLabel.text = item.name;
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

- (UIImageView*)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        [_iconView setX:15];
        [_iconView setWidth:8];
        [_iconView setHeight:8];
        [_iconView setCenterY:[ScheduleTypeCell cellHeight] / 2];
        [_iconView doCircleFrame];
    }
    return _iconView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_titleLabel setWidth:kScreen_Width - CGRectGetMinX(_titleLabel.frame) - 15];
        [_titleLabel setHeight:[ScheduleTypeCell cellHeight]];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}


@end
