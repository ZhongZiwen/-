//
//  LLCenterPickerView.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLCenterPickerView : UIView<UIGestureRecognizerDelegate>{
    UIView *menuView;
    UIDatePicker *_datePickView;
    NSDate *curMinDate;
    NSDate *curSelectDate;
    NSString *selectDateTime;

}


-(id)initWithCurDate:(NSDate *)curDate andMinDate:(NSDate *)minDate headTitle:(NSString *)headTitle dateType:(NSInteger)type;

- (void)showInView:(UIViewController *)Sview;


@property (nonatomic, copy) void (^selectedDateBlock)(NSString *dateTime,NSDate *date);

@end
