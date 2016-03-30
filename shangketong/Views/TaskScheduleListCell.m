//
//  TaskScheduleListCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TaskScheduleListCell.h"
#import "Schedule.h"
#import "Task.h"

@interface TaskScheduleListCell ()

@property (strong, nonatomic) UIButton *taskButton;
@property (strong, nonatomic) UIImageView *scheduleImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *lineView;
@end

@implementation TaskScheduleListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.taskButton];
        [self.contentView addSubview:self.scheduleImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    // 日程
    if ([obj isKindOfClass:[Schedule class]]) {
        Schedule *schedule = obj;
        _taskButton.hidden = YES;
        _scheduleImageView.hidden = NO;
        _scheduleImageView.image = [UIImage imageWithColor:[UIColor colorWithColorType:schedule.colorType.color]];
        _titleLabel.text = schedule.name;
        _timeLabel.text = [schedule.startDate stringTimestampWithoutYear];
        
        [_scheduleImageView setX:15];
        [_titleLabel setX:CGRectGetMaxX(_scheduleImageView.frame) + 10];
        
        return;
    }
    
    // 任务
    Task *task = obj;
    _taskButton.hidden = NO;
    _scheduleImageView.hidden = YES;
    if ([task.taskStatus integerValue] == 3) {
        [_taskButton setImage:[UIImage imageNamed:@"home_today_task_done"] forState:UIControlStateNormal];
    }else {
        [_taskButton setImage:[UIImage imageNamed:@"home_today_task"] forState:UIControlStateNormal];
    }
    _titleLabel.text = task.name;
    _timeLabel.text = [task.date stringTimestampWithoutYear];
    
    [_taskButton setX:15];
    [_titleLabel setX:CGRectGetMaxX(_taskButton.frame) + 10];
}

- (void)taskButtonPress {
    
}

+ (CGFloat)cellHeight {
    return 54.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIButton*)taskButton {
    if (!_taskButton) {
        UIImage *image = [UIImage imageNamed:@"home_today_task"];
        _taskButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_taskButton setX:15];
        [_taskButton setWidth:image.size.width];
        [_taskButton setHeight:image.size.height];
        [_taskButton setCenterY:[TaskScheduleListCell cellHeight] / 2];
        [_taskButton addTarget:self action:@selector(taskButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _taskButton;
}

- (UIImageView*)scheduleImageView {
    if (!_scheduleImageView) {
        _scheduleImageView = [[UIImageView alloc] init];
        [_scheduleImageView setWidth:8];
        [_scheduleImageView setHeight:8];
        [_scheduleImageView setCenterY:[TaskScheduleListCell cellHeight] / 2];
        [_scheduleImageView doCircleFrame];
    }
    return _scheduleImageView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setWidth:kScreen_Width - 64];
        [_titleLabel setHeight:20];
        [_titleLabel setCenterY:[TaskScheduleListCell cellHeight] / 2];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setX:kScreen_Width - 100 - 10];
        [_timeLabel setWidth:100];
        [_timeLabel setHeight:20];
        [_timeLabel setCenterY:[TaskScheduleListCell cellHeight] / 2];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = [UIColor iOS7darkGrayColor];
    }
    return _timeLabel;
}

@end
