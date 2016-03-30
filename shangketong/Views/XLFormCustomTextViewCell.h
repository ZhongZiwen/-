//
//  XLFormCustomTextViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 16/2/23.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import <XLForm/XLForm.h>
#import "UIPlaceHolderTextView.h"

extern NSString *const XLFormRowDescriptorTypeCustomTextView;

@interface XLFormCustomTextViewCell : XLFormBaseCell

@property (copy, nonatomic) UILabel *titleLabel;
@property (copy, nonatomic) UIPlaceHolderTextView *textView;
@end
