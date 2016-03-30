//
//  InputPickerView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "InputPickerView.h"

@interface InputPickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *pickerView;
@end

@implementation InputPickerView

+ (InputPickerView*)sharedPickerView {
    static dispatch_once_t onceToken;
    static InputPickerView *pickerView = nil;
    dispatch_once(&onceToken, ^{
        pickerView = [[InputPickerView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 220)];
    });
    return pickerView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];

        [self addSubview:self.pickerView];
    }
    return self;
}

#pragma mark - UIPickerViewDataSource
// 返回列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// 返回个列行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.sourceArray.count;
}

// 显示各选项内容
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.sourceArray[row];
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"%@", self.sourceArray[row]);
}

#pragma mark - setters and getters
- (UIPickerView*)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:self.bounds];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
    }
    return _pickerView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
