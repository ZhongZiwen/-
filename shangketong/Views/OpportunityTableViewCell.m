//
//  OpportunityTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityTableViewCell.h"
#import "SaleChance.h"

@interface OpportunityTableViewCell ()

@property (strong, nonatomic) UILabel *m_title;
@property (strong, nonatomic) UILabel *m_detail;
@end

@implementation OpportunityTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_title];
        [self.contentView addSubview:self.m_detail];
    }
    return self;
}

- (void)configWithModel:(SaleChance *)model {
    _m_title.text = model.name;
    _m_detail.text = [NSString stringWithFormat:@"%@元 %@", model.money, model.customerName];

    NSMutableArray *rightUtilityButtons = [NSMutableArray arrayWithCapacity:0];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:[model.focus integerValue] ? @"entity_operation_follow" : @"entity_operation_follow_cancel"]];
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:64.0f];
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
- (UILabel*)m_title {
    if (!_m_title) {
        _m_title = [[UILabel alloc] init];
        [_m_title setX:15];
        [_m_title setY:10];
        [_m_title setWidth:kScreen_Width - 15 - 10];
        [_m_title setHeight:20];
        _m_title.font = [UIFont systemFontOfSize:16];
        _m_title.textAlignment = NSTextAlignmentLeft;
    }
    return _m_title;
}

- (UILabel*)m_detail {
    if (!_m_detail) {
        _m_detail = [[UILabel alloc] init];
        [_m_detail setX:CGRectGetMinX(_m_title.frame)];
        [_m_detail setY:CGRectGetMaxY(_m_title.frame) + 4];
        [_m_detail setWidth:CGRectGetWidth(_m_title.bounds)];
        [_m_detail setHeight:20];
        _m_detail.font = [UIFont systemFontOfSize:14];
        _m_detail.textAlignment = NSTextAlignmentLeft;
        _m_detail.textColor = [UIColor lightGrayColor];
    }
    return _m_detail;
}
@end
