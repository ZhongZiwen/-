//
//  TextDetailCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TextFieldInputViewType) {
    TextFieldInputViewTypeDefault,          // 默认键盘，支持所有字符
    TextFieldInputViewTypeDecimalPad,       // 数字键盘
    TextFieldInputViewTypeDatePickerView,   // 时间键盘
    TextFieldInputViewTypePickerView        // 选择器键盘
};

@interface TextDetailCell : UITableViewCell

@property (nonatomic, assign) BOOL isAccessoryView;
@property (nonatomic, assign) BOOL isEdit;

+ (CGFloat)cellHeight;
- (void)configWithText:(NSString*)textStr andDetail:(NSString*)detailStr andInputViewType:(TextFieldInputViewType)type andSourceArray:(NSArray*)sourceArray;
@end
