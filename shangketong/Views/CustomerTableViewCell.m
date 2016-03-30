//
//  CustomerTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomerTableViewCell.h"
#import "Customer.h"

@interface CustomerTableViewCell ()

@property (strong, nonatomic) UILabel *m_title;
@property (strong, nonatomic) UILabel *m_detail;
@end

@implementation CustomerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_title];
        [self.contentView addSubview:self.m_detail];
    }
    return self;
}

- (void)configWithModel:(Customer *)item {
    _m_title.text = item.name;
    
    if (item.expireDate) {
        NSInteger days = [item.expireDate leftDayCount];
        NSInteger hours = [item.expireDate hoursAgo];
        NSInteger minutes = [item.expireDate minutesAgo];
        
        NSString *expireStr;
        NSString *timeStr;
        BOOL isRedColor = NO;
        if (days > 0) {
            if (days <= 3) {
                isRedColor = YES;
            }
            expireStr = [NSString stringWithFormat:@"%ld天后回收", (long)days];
        }
        else if (hours < 0) {
            isRedColor = YES;
            expireStr = [NSString stringWithFormat:@"%ld小时后回收", labs(hours)];
        }
        else if (minutes < 0) {
            isRedColor = YES;
            expireStr = [NSString stringWithFormat:@"%ld分钟后回收", labs(minutes)];
        }
        
        if (expireStr) {
            timeStr = [NSString stringWithFormat:@"%@ | %@", [item.createTime stringTimestampWithoutYear], expireStr];
            if (isRedColor) {
                NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:timeStr];
                [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor iOS7redColor] range:[timeStr rangeOfString:expireStr]];
                _m_detail.attributedText = attributedStr;
            }
            else {
                _m_detail.text = timeStr;
            }
        }
        else {
            _m_detail.text = [NSString stringWithFormat:@"%@", [item.createTime stringTimestampWithoutYear]];
        }
    }else {
        _m_detail.text = [NSString stringWithFormat:@"%@", [item.createTime stringTimestampWithoutYear]];
    }
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray arrayWithCapacity:0];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:[item.focus integerValue] ? @"entity_operation_follow" : @"entity_operation_follow_cancel"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:item.position ? @"entity_operation_lbs" : @"entity_operation_lbs_disable"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:(item.phone ? @"entity_operation_contact" : @"entity_operation_contact_disable")]];
    
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:[CustomerTableViewCell cellHeight]];
}

- (void)configWithoutSWWithItem:(Customer *)item {
    _m_title.text = item.name;
    
    if (item.expireDate) {
        NSInteger days = [item.expireDate leftDayCount];
        NSInteger hours = [item.expireDate hoursAgo];
        NSInteger minutes = [item.expireDate minutesAgo];
        
        NSString *expireStr;
        NSString *timeStr;
        if (days > 0) {
            expireStr = [NSString stringWithFormat:@"%ld天后回收", (long)days];
        }
        else if (hours < 0) {
            expireStr = [NSString stringWithFormat:@"%ld小时后回收", labs(hours)];
        }
        else if (minutes < 0) {
            expireStr = [NSString stringWithFormat:@"%ld分钟后回收", labs(minutes)];
        }
        
        if (expireStr) {
            timeStr = [NSString stringWithFormat:@"%@ | %@", [item.createTime stringTimestampWithoutYear], expireStr];
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:timeStr];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor iOS7redColor] range:[timeStr rangeOfString:expireStr]];
            _m_detail.attributedText = attributedStr;
        }
        else {
            _m_detail.text = [NSString stringWithFormat:@"%@", [item.createTime stringTimestampWithoutYear]];
        }
    }else {
        _m_detail.text = [NSString stringWithFormat:@"%@", [item.createTime stringTimestampWithoutYear]];
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
@end
