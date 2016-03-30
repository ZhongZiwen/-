//
//  InputPickerView.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputPickerView : UIView

@property (nonatomic, strong) NSArray *sourceArray;

+ (InputPickerView*)sharedPickerView;
@end
