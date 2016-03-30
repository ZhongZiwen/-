//
//  ActivityCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityCell.h"
#import "ActivityModel.h"

@interface ActivityCell ()

@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation ActivityCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)configWithItem:(ActivityModel *)item isSwipeable:(BOOL)isSwipeable {
    _titleLabel.text = item.name;
    
    if (isSwipeable) {
        NSMutableArray *rightUtilityButtons = [NSMutableArray arrayWithCapacity:0];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:[item.focus integerValue] ? @"entity_operation_follow" : @"entity_operation_follow_cancel"]];
        [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:64.0f];
    }
}

+ (CGFloat)cellHeight {
    return 64.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setX:15];
        [_titleLabel setWidth:kScreen_Width - 2 * 15];
        [_titleLabel setHeight:[ActivityCell cellHeight]];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}
@end
