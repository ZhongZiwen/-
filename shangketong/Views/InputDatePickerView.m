//
//  InputDatePickerView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "InputDatePickerView.h"

@interface InputDatePickerView ()

@property (nonatomic, strong) UIDatePicker *datePicker;
@end

@implementation InputDatePickerView

+ (InputDatePickerView*)sharedDatePickerView {
    static dispatch_once_t onceToken;
    static InputDatePickerView *datePickerView = nil;
    dispatch_once(&onceToken, ^{
        datePickerView = [[InputDatePickerView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 220)];
    });
    return datePickerView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor lightGrayColor];
        
        _theTypeOfDatePicker = 3;
        
        [self addSubview:self.datePicker];
    }
    return self;
}

#pragma mark - event respoonse
- (void)datePickerEvent:(UIDatePicker*)datePicker {
    NSString *string=[NSString stringWithFormat:@"%@",[NSDate dateWithTimeInterval:3600*8 sinceDate:[_datePicker date]]];
    NSLog(@"%@", string);
}

#pragma mark - setters and getters
- (void)setTheTypeOfDatePicker:(NSInteger)theTypeOfDatePicker {
    if (theTypeOfDatePicker == 1) {
        // 只显示时间
        _datePicker.datePickerMode = UIDatePickerModeTime;
    }else if (theTypeOfDatePicker == 2) {
        // 只显示日期
        _datePicker.datePickerMode = UIDatePickerModeDate;
    }else {
        // 时间和日期都显示
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
}

- (UIDatePicker*)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:self.bounds];
        _datePicker.date = [NSDate date];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        [_datePicker addTarget:self action:@selector(datePickerEvent:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
