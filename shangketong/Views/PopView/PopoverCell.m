//
//  PopoverCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PopoverCell.h"
#import "PopoverItem.h"

@interface PopoverCell ()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation PopoverCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithHexString:@"0x28303b"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    PopoverItem *item = obj;
    
    _titleLabel.text = item.title;
    
    if (item.image) {
        _iconView.hidden = NO;
        _iconView.image = item.image;
        
        [_titleLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_titleLabel setWidth:kTableViewWidth - CGRectGetMinX(_titleLabel.frame) - 10];
        
    }else {
        _iconView.hidden = YES;
        
        [_titleLabel setX:10];
        [_titleLabel setWidth:kTableViewWidth - 10 - 10];
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

- (UIImageView*)iconView {
    if (!_iconView) {
        UIImage *image = [UIImage imageNamed:@"followup_schedule"];
        _iconView = [[UIImageView alloc] init];
        [_iconView setX:10];
        [_iconView setWidth:image.size.width];
        [_iconView setHeight:image.size.height];
        [_iconView setCenterY:[PopoverCell cellHeight] / 2];
    }
    return _iconView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setHeight:30];
        [_titleLabel setCenterY:[PopoverCell cellHeight] / 2];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}
@end
