//
//  ContactTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "Contact.h"

@interface ContactTableViewCell ()

@property (strong, nonatomic) UILabel *m_title;
@property (strong, nonatomic) UILabel *m_detail;
@end

@implementation ContactTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.m_title];
        [self.contentView addSubview:self.m_detail];
    }
    return self;
}

- (void)configWithModel:(Contact *)item {
    _m_title.text = item.name;
    _m_detail.text = item.companyName;
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray arrayWithCapacity:0];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:item.position ? @"entity_operation_lbs" : @"entity_operation_lbs_disable"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:(item.phone || item.mobile ? @"entity_operation_contact" : @"entity_operation_contact_disable")]];
    
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:[ContactTableViewCell cellHeight]];
}

- (void)configWithoutSWWithItem:(Contact *)item {
    _m_title.text = item.name;
    _m_detail.text = item.companyName;
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
        [_m_title setHeight:24];
        _m_title.font = [UIFont systemFontOfSize:16];
        _m_title.textAlignment = NSTextAlignmentLeft;
    }
    return _m_title;
}

- (UILabel*)m_detail {
    if (!_m_detail) {
        _m_detail = [[UILabel alloc] init];
        [_m_detail setX:CGRectGetMinX(_m_title.frame)];
        [_m_detail setY:CGRectGetMaxY(_m_title.frame)];
        [_m_detail setWidth:CGRectGetWidth(_m_title.bounds)];
        [_m_detail setHeight:20];
        _m_detail.font = [UIFont systemFontOfSize:14];
        _m_detail.textAlignment = NSTextAlignmentLeft;
        _m_detail.textColor = [UIColor lightGrayColor];
    }
    return _m_detail;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
