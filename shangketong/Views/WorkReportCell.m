//
//  WorkReportCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WorkReportCell.h"
#import "WorkReportItem.h"
#import "NSString+Common.h"
#import "UIView+Common.h"
#import <UIImageView+WebCache.h>
#import "CommonConstant.h"
#import "CommonFuntion.h"

#define kStatusLabelWidth    30

@interface WorkReportCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation WorkReportCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.statusLabel];
    }
    return self;
}

- (void)configWithModel:(WorkReportItem *)item andReportType:(NSInteger)type {
    if (type == 0) {
        _iconImageView.hidden = YES;
        
        [_contentLabel setX:15];
        [_timeLabel setX:15];
    }else {
        _iconImageView.hidden = NO;
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:item.m_creatorIcon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
        
        [_contentLabel setX:70];
        [_timeLabel setX:70];
    }
    
    NSString *dateStr = @"";
    switch (item.m_reportTypeIndex) {
        case 0:
            dateStr = [NSString transDateWithTimeInterval:item.m_reportTime andCustomFormate:@"yyyy-MM-dd"];
            break;
        case 1:
            dateStr = [NSString transDateToNumberOfWeekInMonthWithTimeInterval:item.m_reportTime];
            break;
        case 2:
        {
            NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[item.m_reportTime longLongValue] / 1000.0];
            dateStr = [lastDate stringYearMonth];
//            dateStr = [NSString transDateWithTimeInterval:item.m_reportTime andCustomFormate:@"yyyy年MM月"];
        }
            break;
        default:
            break;
    }
    _contentLabel.text = [NSString stringWithFormat:@"%@【%@】", item.m_reportTypeName, dateStr];
    
    if (item.m_paperStatus) {   // 草稿
        _statusLabel.hidden = YES;
        
        
        NSString *createStr = [CommonFuntion getStringForTime:[item.m_createAt longLongValue]];
        NSInteger v = [CommonFuntion getTimeDaysSinceToady:createStr];
        NSString *newCreateStr = @"";
        if (v == 0) {
            newCreateStr = [NSString stringWithFormat:@"今天%@",[createStr substringFromIndex:10]];
        } else if (v == 1) {
            newCreateStr = [NSString stringWithFormat:@"昨天%@",[createStr substringFromIndex:10]];
        } else {
            newCreateStr = [createStr substringFromIndex:5];
        }
        
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[草稿] %@", newCreateStr]];
        
//        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[草稿] %@", [NSString msgRemindApprovalTransDateWithTimeInterval:item.m_createAt]]];
        [attributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, 4)];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
        _timeLabel.attributedText = attributedStr;
    }else {
//        _timeLabel.text = [NSString msgRemindApprovalTransDateWithTimeInterval:item.m_createAt];
        NSString *createStr = [CommonFuntion getStringForTime:[item.m_createAt longLongValue]];
        NSInteger v = [CommonFuntion getTimeDaysSinceToady:createStr];
        NSString *newCreateStr = @"";
        if (v == 0) {
            newCreateStr = [NSString stringWithFormat:@"今天%@",[createStr substringFromIndex:10]];
        } else if (v == 1) {
            newCreateStr = [NSString stringWithFormat:@"昨天%@",[createStr substringFromIndex:10]];
        } else {
            newCreateStr = [createStr substringFromIndex:5];
        }
        _timeLabel.text = newCreateStr;
        
        _statusLabel.hidden = YES;
        /// 1未阅
        if (item.m_readStatus) {
            if ([item.m_reveiwerId integerValue] == [appDelegateAccessor.moudle.userId integerValue] || [item.m_creatorId integerValue] == [appDelegateAccessor.moudle.userId integerValue]) {
                _statusLabel.hidden = NO;
            }
        }
    }
}

+ (CGFloat)cellHeight {
    return 60.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIImageView*)iconImageView {
    if (!_iconImageView) {
        _iconImageView =[[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 40)];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.clipsToBounds = YES;
        
    }
    return _iconImageView;
}

- (UILabel*)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + 40 + 10, 10, kScreen_Width - 30, 20)];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _contentLabel;
}

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + 40 + 10, 30, kScreen_Width - 30, 20)];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}

- (UILabel*)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 20 - kStatusLabelWidth, ([WorkReportCell cellHeight] - 20) / 2.0, kStatusLabelWidth, 20)];
        _statusLabel.font = [UIFont systemFontOfSize:10];
        _statusLabel.layer.cornerRadius = 2;
        _statusLabel.layer.borderWidth = 0.5;
        _statusLabel.layer.borderColor = [UIColor redColor].CGColor;
        _statusLabel.layer.masksToBounds = YES;
        _statusLabel.clipsToBounds = YES;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.textColor = [UIColor redColor];
        _statusLabel.text = @"未阅";
    }
    return _statusLabel;
}
@end
