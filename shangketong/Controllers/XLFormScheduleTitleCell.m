//
//  XLFormScheduleTitleCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormScheduleTitleCell.h"
#import "ScheduleDetail.h"

#define kPaddingLeftWidth 15

NSString *const XLFormRowDescriptorTypeScheduleTitle = @"XLFormRowDescriptorTypeScheduleTitle";

@interface XLFormScheduleTitleCell ()

@property (strong, nonatomic) UIImageView *typeIconView;
@property (strong, nonatomic) UILabel *typeNameLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@end

@implementation XLFormScheduleTitleCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFormScheduleTitleCell class] forKey:XLFormRowDescriptorTypeScheduleTitle];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.typeIconView];
    [self.contentView addSubview:self.typeNameLabel];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.timeLabel];
}

- (void)update {
    [super update];
    
    ScheduleDetail *value = self.rowDescriptor.value;
    
    _typeIconView.image = [UIImage imageWithColor:[UIColor colorWithColorType:value.colorType.color]];
    _typeNameLabel.text = value.colorType.name ? : @"其他";
    _nameLabel.text = value.name;
    if (![value.isAllDay integerValue]) {   // 全天
        _timeLabel.text = [NSString stringWithFormat:@"%@ - %@", [value.startDate stringYearMonthDayForLine], [value.endDate stringYearMonthDayForLine]];
    }else {
        _timeLabel.text = [NSString stringWithFormat:@"%@ - %@", [value.startDate stringTimestamp], [value.endDate stringTimestamp]];
    }
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 84.0f;
}

- (UIImageView*)typeIconView {
    if (!_typeIconView) {
        _typeIconView = [[UIImageView alloc] init];
        [_typeIconView setX:kPaddingLeftWidth];
        [_typeIconView setWidth:8];
        [_typeIconView setHeight:8];
        [_typeIconView setCenterY:17.5];
        [_typeIconView doCircleFrame];
    }
    return _typeIconView;
}

- (UILabel*)typeNameLabel {
    if (!_typeNameLabel) {
        _typeNameLabel = [[UILabel alloc] init];
        [_typeNameLabel setX:CGRectGetMaxX(_typeIconView.frame) + 5];
        [_typeNameLabel setY:10];
        [_typeNameLabel setWidth:kScreen_Width - CGRectGetMinX(_typeNameLabel.frame) - 44];
        [_typeNameLabel setHeight:15];
        _typeNameLabel.font = [UIFont systemFontOfSize:12];
        _typeNameLabel.textColor = [UIColor iOS7darkGrayColor];
        _typeNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _typeNameLabel;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:kPaddingLeftWidth];
        [_nameLabel setY:CGRectGetMaxY(_typeNameLabel.frame) + 5];
        [_nameLabel setWidth:kScreen_Width - 15 - 44];
        [_nameLabel setHeight:24];
        _nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setX:kPaddingLeftWidth];
        [_timeLabel setY:CGRectGetMaxY(_nameLabel.frame) + 5];
        [_timeLabel setWidth:CGRectGetWidth(_nameLabel.bounds)];
        [_timeLabel setHeight:15];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor iOS7darkGrayColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
