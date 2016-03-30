//
//  XLFormCustomDateCell.h
//  shangketong
//
//  Created by sungoin-zbs on 16/3/11.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import <XLForm/XLForm.h>

extern NSString * const XLFormRowDescriptorTypeCustomDate;

typedef NS_ENUM(NSUInteger, XLFormCustomDateDatePickerMode) {
    XLFormCustomDateDatePickerModeDate,
    XLFormCustomDateDatePickerModeDateTime,
    XLFormCustomDateDatePickerModeTime
};

@interface XLFormCustomDateCell : XLFormBaseCell

@property (nonatomic) XLFormCustomDateDatePickerMode formDatePickerMode;
@property (nonatomic) NSDate *minimumDate;
@property (nonatomic) NSDate *maximumDate;
@property (nonatomic) NSInteger minuteInterval;
@end
