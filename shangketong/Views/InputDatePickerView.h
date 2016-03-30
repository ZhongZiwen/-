//
//  InputDatePickerView.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputDatePickerView : UIView

@property (nonatomic, assign) NSInteger theTypeOfDatePicker;    // 显示类别 1=只显示时间,2=只显示日期，3=显示日期和时间(默认为3)

+ (InputDatePickerView*)sharedDatePickerView;
@end
