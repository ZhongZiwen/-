//
//  LLCenterYYYYMMPickerView.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRMonthPicker.h"

@interface LLCenterYYYYMMPickerView : UIView<UIGestureRecognizerDelegate,SRMonthPickerDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    UIView *menuView;
    SRMonthPicker *_datePickView;
    NSString *curSelectDate;
    
    UIPickerView *_pickerView;
    NSArray *_arrayPcikerview;
}


-(id)initWithMaxYear:(NSNumber*) maximumYear andMinYear:(NSNumber*) minimumYear andTitle:(NSString *)headTitle  andData:(NSArray *)data andType:(NSInteger)type;

- (void)showInView:(UIViewController *)Sview;


@property (nonatomic, copy) void (^selectedDateBlock)(NSString *selectedDate);

@end
