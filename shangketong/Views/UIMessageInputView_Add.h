//
//  UIMessageInputView_Add.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMessageInputView_Add : UIView

@property (copy, nonatomic) void(^addButtonClickBlock)(NSInteger index);
@end
