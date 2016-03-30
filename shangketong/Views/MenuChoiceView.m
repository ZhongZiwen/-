//
//  MenuChoiceView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MenuChoiceView.h"
#import <POP.h>
#import "NSString+Common.h"
#import "UIView+Common.h"

#define kBlueColor [UIColor colorWithRed:(CGFloat)70/255.0 green:(CGFloat)154/255.0 blue:(CGFloat)234/255.0 alpha:1.0]
@interface MenuChoiceView ()

@property (nonatomic, strong) UIView *bottomView;   // 状态横线
@property (nonatomic, assign) NSInteger index;
@end

@implementation MenuChoiceView

- (id)initWithFrame:(CGRect)frame withDefaultIndex:(NSInteger)index {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _index = index;
        [self addSubview:self.bottomView];
    }
    return self;
}

- (void)buttonPress:(UIButton*)sender {
    
    self.index = sender.tag - 200;
}

#pragma mark - Private Method
- (void)popAnimationWithIndex:(NSInteger)index {
    
    POPSpringAnimation *animation = [POPSpringAnimation animation];
    animation.property = [POPAnimatableProperty propertyWithName:kPOPViewCenter];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake((2*index+1)*(CGRectGetWidth(self.bounds)/(_menuArray.count * 2)), CGRectGetHeight(self.bounds)-1)];
    animation.springBounciness = 10.0;
    animation.springSpeed = 50.0;
    animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (self.selectedBlock) {
            self.selectedBlock(_index);
        }
    };
    [_bottomView pop_addAnimation:animation forKey:@"center"];
}

#pragma mark - setters and getters
- (void)setIndex:(NSInteger)index {
    if (_index == index)
        return;
    
    UIButton *preButton = (UIButton*)[self viewWithTag:_index + 200];
    [preButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    _index = index;
    
    UIButton *currentButton = (UIButton*)[self viewWithTag:_index + 200];
    [currentButton setTitleColor:kBlueColor forState:UIControlStateNormal];
    
    [_bottomView setWidth:[_menuArray[_index] getWidthWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20)]];
    [self popAnimationWithIndex:_index];
}

- (void)setMenuArray:(NSArray *)menuArray {
    if (!menuArray.count)
        return;

    _menuArray = menuArray;
    
    for (int i = 0; i < menuArray.count; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i * CGRectGetWidth(self.bounds) / menuArray.count, 0, CGRectGetWidth(self.bounds) / menuArray.count, CGRectGetHeight(self.bounds));
        button.tag = 200 + i;
        [button setTitle:menuArray[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:(i == _index ? kBlueColor : [UIColor blackColor]) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        if (i == _index) {
            [_bottomView setWidth:[menuArray[i] getWidthWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20)]];
            [_bottomView setCenter:CGPointMake((2*i+1)*(CGRectGetWidth(self.bounds)/(_menuArray.count * 2)), CGRectGetHeight(self.bounds)-1)];
        }
    }
}

- (UIView*)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
        _bottomView.backgroundColor = kBlueColor;
    }
    return _bottomView;
}



- (void)setIndexSelect:(NSInteger)index {
    if (_index == index)
        return;
    
    UIButton *preButton = (UIButton*)[self viewWithTag:_index + 200];
    [preButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    _index = index;
    
    UIButton *currentButton = (UIButton*)[self viewWithTag:_index + 200];
    [currentButton setTitleColor:kBlueColor forState:UIControlStateNormal];
    
    [_bottomView setWidth:[_menuArray[_index] getWidthWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20)]];
    POPSpringAnimation *animation = [POPSpringAnimation animation];
    animation.property = [POPAnimatableProperty propertyWithName:kPOPViewCenter];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake((2*index+1)*(CGRectGetWidth(self.bounds)/(_menuArray.count * 2)), CGRectGetHeight(self.bounds)-1)];
    animation.springBounciness = 10.0;
    animation.springSpeed = 50.0;
   
    [_bottomView pop_addAnimation:animation forKey:@"center"];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
