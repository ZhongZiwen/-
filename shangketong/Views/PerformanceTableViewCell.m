//
//  PerformanceTableViewCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PerformanceTableViewCell.h"
#import "PerformanceItem.h"
#import "UIView+Common.h"

@interface PerformanceTableViewCell ()

@property (nonatomic, strong) UILabel *m_content;   // 内容
@property (nonatomic, strong) UILabel *owner;
@property (nonatomic, strong) UILabel *m_owner;     // 负责人
@property (nonatomic, strong) UILabel *account;
@property (nonatomic, strong) UILabel *m_account;   // 客户名称
@property (nonatomic, strong) UILabel *money;
@property (nonatomic, strong) UILabel *m_money;     // 金额

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation PerformanceTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_content];
        [self.contentView addSubview:self.owner];
        [self.contentView addSubview:self.m_owner];
        [self.contentView addSubview:self.account];
        [self.contentView addSubview:self.m_account];
        [self.contentView addSubview:self.money];
        [self.contentView addSubview:self.m_money];
    }
    return self;
}

- (void)configWithItem:(PerformanceItem *)item {
    _m_content.text = [NSString stringWithFormat:@"%@", item.m_name];
    _m_owner.text = [NSString stringWithFormat:@"%@", item.m_ownerId];
    _m_account.text = [NSString stringWithFormat:@"%@", item.m_accountId];
    _m_money.text = [NSString stringWithFormat:@"%@元", [self.numberFormatter stringFromNumber:[NSNumber numberWithInteger:item.m_money]]];
}

+ (CGFloat)cellHeightWithItem:(PerformanceItem *)item {
    return 125;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UILabel*)m_content {
    if (!_m_content) {
        _m_content = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, kScreen_Width - 20, 30)];
        _m_content.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        _m_content.textAlignment = NSTextAlignmentLeft;
        _m_content.textColor = [UIColor blackColor];
    }
    return _m_content;
}

- (UILabel*)owner {
    if (!_owner) {
        _owner = [[UILabel alloc] initWithFrame:CGRectMake(10, 10 + 30 + 5, 100, 20)];
        _owner.font = [UIFont systemFontOfSize:14];
        _owner.textAlignment = NSTextAlignmentLeft;
        _owner.textColor = [UIColor lightGrayColor];
        _owner.text = @"负责人";
    }
    return _owner;
}

- (UILabel*)m_owner {
    if (!_m_owner) {
        _m_owner = [[UILabel alloc] initWithFrame:CGRectMake(10 + CGRectGetWidth(_owner.bounds), _owner.frame.origin.y, kScreen_Width - 20 - CGRectGetWidth(_owner.bounds), 20)];
        _m_owner.font = [UIFont systemFontOfSize:14];
        _m_owner.textAlignment = NSTextAlignmentLeft;
        _m_owner.textColor = [UIColor lightGrayColor];
    }
    return _m_owner;
}

- (UILabel*)account {
    if (!_account) {
        _account = [[UILabel alloc] initWithFrame:CGRectMake(10, _owner.frame.origin.y + CGRectGetHeight(_owner.bounds) + 5, CGRectGetWidth(_owner.bounds), 20)];
        _account.font = [UIFont systemFontOfSize:14];
        _account.textAlignment = NSTextAlignmentLeft;
        _account.textColor = [UIColor lightGrayColor];
        _account.text = @"客户名称";
    }
    return _account;
}

- (UILabel*)m_account {
    if (!_m_account) {
        _m_account = [[UILabel alloc] initWithFrame:CGRectMake(10 + CGRectGetWidth(_account.bounds), _account.frame.origin.y, kScreen_Width - 20 - CGRectGetWidth(_account.bounds), 20)];
        _m_account.font = [UIFont systemFontOfSize:14];
        _m_account.textAlignment = NSTextAlignmentLeft;
        _m_account.textColor = [UIColor lightGrayColor];
    }
    return _m_account;
}

- (UILabel*)money {
    if (!_money) {
        _money = [[UILabel alloc] initWithFrame:CGRectMake(10, _account.frame.origin.y + CGRectGetHeight(_account.bounds) + 5, CGRectGetWidth(_account.bounds), 20)];
        _money.font = [UIFont systemFontOfSize:14];
        _money.textAlignment = NSTextAlignmentLeft;
        _money.textColor = [UIColor lightGrayColor];
        _money.text = @"金额";
    }
    return _money;
}

- (UILabel*)m_money {
    if (!_m_money) {
        _m_money = [[UILabel alloc] initWithFrame:CGRectMake(10 + CGRectGetWidth(_money.bounds), _money.frame.origin.y, kScreen_Width - 20 - CGRectGetWidth(_money.bounds), 20)];
        _m_money.font = [UIFont systemFontOfSize:14];
        _m_money.textAlignment = NSTextAlignmentLeft;
        _m_money.textColor = [UIColor lightGrayColor];
    }
    return _m_money;
}

- (NSNumberFormatter*)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    }
    return _numberFormatter;
}

@end
