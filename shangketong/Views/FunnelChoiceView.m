//
//  FunnelChoiceView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FunnelChoiceView.h"
#import <POP.h>

@interface FunnelChoiceView ()

@property (nonatomic, strong) UIView *lineView;     // 标识线
@property (nonatomic, assign) NSInteger index;
@end

@implementation FunnelChoiceView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        NSArray *titleArray = @[@"按金钱排序", @"按时间排序"];
        int i = 0;
        for (NSString *title in titleArray) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(i * CGRectGetWidth(self.bounds)/2, 0, CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds));
            button.tag = 200 + i;
            [button setTitle:title forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleColor:(i == 0 ? kTitleColor : [UIColor blackColor]) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            i ++;
        }
        
        [self addSubview:self.lineView];
        
        _index = 0;
    }
    return self;
}

- (void)setIndex:(NSInteger)index {
    
    if (_index == index)
        return;
    
    UIButton *preButton = (UIButton*)[self viewWithTag:_index + 200];
    [preButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    _index = index;
    
    UIButton *currentButton = (UIButton*)[self viewWithTag:_index + 200];
    [currentButton setTitleColor:kTitleColor forState:UIControlStateNormal];
    
    [self popAnimationWithIndex:_index];
    
    if (self.selectedBlock) {
        self.selectedBlock(_index);
    }
}

#pragma mark - Private Method
- (void)popAnimationWithIndex:(NSInteger)index {
    
    POPSpringAnimation *animation = [POPSpringAnimation animation];
    animation.property = [POPAnimatableProperty propertyWithName:kPOPViewCenter];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake((2*index+1)*(CGRectGetWidth(self.bounds)/4.0), CGRectGetHeight(self.bounds)-1)];
    animation.springBounciness = 10.0;
    animation.springSpeed = 50.0;
    [_lineView pop_addAnimation:animation forKey:@"center"];
}

- (void)buttonPress:(UIButton*)sender {
    
    self.index = sender.tag - 200;
}

#pragma mark - setters and getters
- (UIView*)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 74, 2)];
        [_lineView setCenter:CGPointMake((CGRectGetWidth(self.bounds)/4.0), CGRectGetHeight(self.bounds)-1)];
        _lineView.backgroundColor = kTitleColor;
    }
    return _lineView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
