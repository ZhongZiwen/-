//
//  MsgRemindCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MsgRemindCell.h"
#import "RemindModel.h"
#import "NSString+Common.h"

@interface MsgRemindCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_titleLabel;
@property (nonatomic, strong) UILabel *m_detailLabel;
@property (nonatomic, strong) UILabel *m_timeLabel;
@property (nonatomic, strong) UILabel *flagLabel; //标记是否已读
@end

@implementation MsgRemindCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_imageView];
        [self.contentView addSubview:self.m_titleLabel];
        [self.contentView addSubview:self.m_detailLabel];
        [self.contentView addSubview:self.m_timeLabel];
        [self.contentView addSubview:self.flagLabel];
    }
    return self;
}

- (void)configWithModel:(RemindModel *)model {
//    _m_imageView.image = [UIImage imageNamed:@"user_icon_default_90"];
    [_m_imageView sd_setImageWithURL:[NSURL URLWithString:model.user_icon] placeholderImage:[UIImage imageNamed:@"user_icon_default_90"]];
    _m_titleLabel.text = model.user_name;
//    _m_timeLabel.text = [NSString msgRemindTransDateWithTimeInterval:model.m_createdTime];
    
    NSString *timeStr = [CommonFuntion getStringForTime:[model.m_createdTime longLongValue]];
    NSInteger value = [CommonFuntion getTimeDaysSinceToady:timeStr];
    if (value == 0) {
        timeStr = [timeStr substringWithRange:NSMakeRange(11, 5)];
    } else if (value == 1) {
        timeStr = @"昨天";
    } else if (value > 1 && value <=7) {
        NSArray *weekDaysArray = @[@"星期日", @"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[model.m_createdTime longLongValue] / 1000];
        NSInteger index = [CommonFuntion getCurDateWeekday:date];
        timeStr = [weekDaysArray objectAtIndex:index - 1];
    } else {
        timeStr = [timeStr substringToIndex:10];
    }
    _m_timeLabel.text = timeStr;

    
    CGFloat detailHeight = [model.m_content getHeightWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(kScreen_Width - 30 - 44, MAXFLOAT)];
    CGRect frame = _m_detailLabel.frame;
    if (detailHeight > 20) {
        frame.size.height = detailHeight;
    }else {
        frame.size.height = 20;
    }
    _m_detailLabel.frame = frame;
    _m_detailLabel.text = model.m_content;
    if ([model.isRead isEqualToString:@"0"]) {
         _flagLabel.hidden = YES;
    } else {
         _flagLabel.hidden = NO;
    }
   
}

+ (CGFloat)cellHeightWithModel:(RemindModel *)model {
    CGFloat detailHeight = [model.m_content getHeightWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(kScreen_Width - 30 - 44, MAXFLOAT)];
    if (detailHeight > 20) {
        return 10 + 22 + detailHeight + 10;
    }else {
        return 10 + 22 + 20 + 10;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
        _m_imageView.layer.masksToBounds = YES;
        _m_imageView.contentMode = UIViewContentModeScaleAspectFill;
        _m_imageView.clipsToBounds = YES;
    }
    return _m_imageView;
}

- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_imageView.frame.origin.x + CGRectGetWidth(_m_imageView.bounds) + 10, _m_imageView.frame.origin.y, 150, 22)];
        _m_titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        _m_titleLabel.textColor = [UIColor blackColor];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_titleLabel;
}

- (UILabel*)m_detailLabel {
    if (!_m_detailLabel) {
        _m_detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_titleLabel.frame.origin.x, _m_titleLabel.frame.origin.y + CGRectGetHeight(_m_titleLabel.bounds), kScreen_Width - _m_titleLabel.frame.origin.x - 20, 0)];
        _m_detailLabel.font = [UIFont systemFontOfSize:13];
        _m_detailLabel.textColor = [UIColor grayColor];
        _m_detailLabel.textAlignment = NSTextAlignmentLeft;
        _m_detailLabel.numberOfLines = 0;
        _m_detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _m_detailLabel;
}

- (UILabel*)m_timeLabel {
    if (!_m_timeLabel) {
        _m_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 20 - 100, 10, 100, 22)];
        _m_timeLabel.font = [UIFont systemFontOfSize:13];
        _m_timeLabel.textAlignment = NSTextAlignmentRight;
        _m_timeLabel.textColor = [UIColor lightGrayColor];
    }
    return _m_timeLabel;
}
- (UILabel *)flagLabel {
    if (!_flagLabel) {
        _flagLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 10, 10, 10)];
        _flagLabel.layer.masksToBounds = YES;
        _flagLabel.layer.cornerRadius = 5;
        _flagLabel.backgroundColor = [UIColor redColor];
    }
    return _flagLabel;
}
@end
