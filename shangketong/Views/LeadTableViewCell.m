//
//  LeadTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LeadTableViewCell.h"
#import "Lead.h"

@interface LeadTableViewCell ()

@property (strong, nonatomic) UILabel *m_title;
@property (strong, nonatomic) UILabel *m_detail;
@property (strong, nonatomic) UILabel *timeLabel;
@end

@implementation LeadTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.m_title];
        [self.contentView addSubview:self.m_detail];
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

- (void)configWithModel:(Lead *)item {
    _m_title.text = item.name;
    _m_detail.text = item.companyName;
    
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
                _timeLabel.attributedText = attributedStr;
            }
            else {
                _timeLabel.text = timeStr;
            }
        }
        else {
            _timeLabel.text = [NSString stringWithFormat:@"%@", [item.createTime stringTimestampWithoutYear]];
        }
    }else {
        _timeLabel.text = [NSString stringWithFormat:@"%@", [item.createTime stringTimestampWithoutYear]];
    }
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray arrayWithCapacity:0];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:item.position ? @"entity_operation_lbs" : @"entity_operation_lbs_disable"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:(item.phone || item.mobile ? @"entity_operation_contact" : @"entity_operation_contact_disable")]];
    
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:64.0f];
}

+ (CGFloat)cellHeight {
    return 84;
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
        _m_title = [[UILabel alloc] initWithFrame:CGRectZero];
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
        _m_detail = [[UILabel alloc] initWithFrame:CGRectZero];
        [_m_detail setX:15];
        [_m_detail setY:CGRectGetMaxY(_m_title.frame)];
        [_m_detail setWidth:kScreen_Width - 15 - 10];
        [_m_detail setHeight:20];
        _m_detail.font = [UIFont systemFontOfSize:14];
        _m_detail.textAlignment = NSTextAlignmentLeft;
        _m_detail.textColor = [UIColor lightGrayColor];
    }
    return _m_detail;
}

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setX:15];
        [_timeLabel setY:CGRectGetMaxY(_m_detail.frame)];
        [_timeLabel setWidth:CGRectGetWidth(_m_detail.bounds)];
        [_timeLabel setHeight:20];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.textColor = [UIColor lightGrayColor];
    }
    return _timeLabel;
}

@end
