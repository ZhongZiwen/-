//
//  ActivityRecordTitleCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordTitleCell.h"
#import "NSDate+Helper.h"

@interface ActivityRecordTitleCell ()

@property (strong, nonatomic) UIImageView *iView;
@property (strong, nonatomic) UILabel *title;
@end

@implementation ActivityRecordTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.iView];
        [self.contentView addSubview:self.title];
    }
    return self;
}

- (void)configWithType:(NSInteger)type {
    
    if (type == 0) {
        _title.text = [[NSDate date] stringYearMonthDayForLine];
    }
    else if (type == 1) {
        _title.text = [[NSDate dateYesterday] stringYearMonthDayForLine];
    }
    else if (type == 2) {
        _title.text = [NSString stringWithFormat:@"%@ 至 %@", [[NSDate dateStartOfWeek] stringYearMonthDayForLine], [[NSDate dateEndOfWeek] stringYearMonthDayForLine]];
    }
    else {
        _title.text = [NSString stringWithFormat:@"%@ 至 %@", [[[NSDate dateStartOfWeek] dateBySubtractingDays:7] stringYearMonthDayForLine], [[[NSDate dateStartOfWeek] dateBySubtractingDays:1] stringYearMonthDayForLine]];
    }
}

- (void)configWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    if ([NSDate daysOffsetBetweenStartDate:startDate endDate:endDate] == 0) {
        _title.text = [startDate stringYearMonthDayForLine];
    }else {
        _title.text = [NSString stringWithFormat:@"%@ 至 %@", [startDate stringYearMonthDayForLine], [endDate stringYearMonthDayForLine]];
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

#pragma mark - setters and getters
- (UIImageView*)iView {
    if (!_iView) {
        UIImage *image = [UIImage imageNamed:@"dashboard_date"];
        _iView = [[UIImageView alloc] initWithImage:image];
        [_iView setX:10];
        [_iView setWidth:image.size.width];
        [_iView setHeight:image.size.height];
        [_iView setCenterY:[ActivityRecordTitleCell cellHeight] / 2];
    }
    return _iView;
}

- (UILabel*)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        [_title setX:CGRectGetMaxX(_iView.frame) + 10];
        [_title setWidth:200];
        [_title setHeight:20];
        [_title setCenterY:CGRectGetMidY(_iView.frame)];
        _title.font = [UIFont systemFontOfSize:13];
        _title.textColor = [UIColor iOS7darkGrayColor];
        _title.textAlignment = NSTextAlignmentLeft;
    }
    return _title;
}

@end
