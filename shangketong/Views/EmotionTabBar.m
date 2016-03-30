
//
//  EmotionTabBar.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EmotionTabBar.h"
#import "UIView+Common.h"
#import "UIColor+expanded.h"

#define kButtonWidth    60.0
#define kButtonTag      35436

@interface EmotionTabBar ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *imagesArray;
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation EmotionTabBar

- (instancetype)initWithFrame:(CGRect)frame andButtonImages:(NSArray *)imagesArray {
    self = [super initWithFrame:frame];
    if (self) {
        [self addLineUp:YES andDown:NO andColor:[UIColor colorWithHexString:@"0xdddddd"]];
        self.imagesArray = [NSArray arrayWithArray:imagesArray];
        
        [self addSubview:self.scrollView];
        [self addSubview:self.senderButton];
        
        self.selectedIndex = 0;
    }
    return self;
}

#pragma mark - event response
- (void)tabButtonPress:(UIButton*)sender {
    if (_selectedIndex != (sender.tag - kButtonTag)) {
        self.selectedIndex = sender.tag - kButtonTag;
        if (self.selectedIndexChangedBlock) {
            self.selectedIndexChangedBlock(_selectedIndex);
        }
    }
}

- (void)senderButtonPress {
    if (self.sendButtonClickedBlock) {
        self.sendButtonClickedBlock();
    }
}

#pragma mark - private methods
- (UIButton*)tabButtonWithIndex:(NSInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(kButtonWidth*index, 0, kButtonWidth, CGRectGetHeight(self.bounds));
    button.tag = kButtonTag + index;
    [button setImage:[UIImage imageNamed:_imagesArray[index]] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(tabButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kButtonWidth-0.5, 0, 0.5, CGRectGetHeight(self.bounds))];
    lineView.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
    [button addSubview:lineView];
    
    return button;
}

#pragma mark - setters and getters
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    
    for (int i = 0; i < self.imagesArray.count; i ++) {
        UIButton *button = (UIButton*)[self viewWithTag:kButtonTag + i];
        if (i == _selectedIndex) {
            button.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        }else {
            button.backgroundColor = [UIColor clearColor];
        }
    }
}

- (UIScrollView*)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - kButtonWidth, CGRectGetHeight(self.bounds))];
        
        // 初始化按钮
        for (int i = 0; i < self.imagesArray.count; i ++) {
            UIButton *button = [self tabButtonWithIndex:i];
            [_scrollView addSubview:button];
        }
    }
    return _scrollView;
}

- (UIButton*)senderButton {
    if (!_senderButton) {
        _senderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _senderButton.frame = CGRectMake(kScreen_Width - kButtonWidth, 0, kButtonWidth, CGRectGetHeight(self.bounds));
        _senderButton.backgroundColor = [UIColor colorWithHexString:@"0x3bbd79"];
        _senderButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_senderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_senderButton setTitle:@"发送" forState:UIControlStateNormal];
        [_senderButton addTarget:self action:@selector(senderButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _senderButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
