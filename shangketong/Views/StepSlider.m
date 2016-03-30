//
//  StepSlider.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "StepSlider.h"
#import "UIView+Common.h"

@interface StepSlider ()

@property (nonatomic) CGPoint diffPoint;
@property (nonatomic, strong) UIButton *thumbButton;
@property (nonatomic, strong) UIImageView *trackImageView;

/** 判断停止移动后坐标符合conditionArray中的哪一段， 返回index*/
- (NSInteger)getIndexInConditionArray:(CGFloat)pointX;

/** 根据条件设置thumbbutton坐标*/
- (void)animateToIndex:(NSInteger)index;
@end

@implementation StepSlider

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        //        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.trackImageView];
        [self addSubview:self.thumbButton];
    }
    return self;
}

- (void)layoutSubviews {
    
    [_trackImageView setWidth:CGRectGetWidth(self.bounds)];
    
    [super layoutSubviews];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (NSInteger)getIndexInConditionArray:(CGFloat)pointX {
    
    for (int i = 0; i < _conditionArray.count; i ++) {
        if (pointX <= [_conditionArray[i] floatValue]) {
            return i;
        }
    }
    return _conditionArray.count - 1;
}

- (void)animateToIndex:(NSInteger)index {
    CGFloat pointX = [_locationArray[index] floatValue];
    [UIView animateWithDuration:0.1 animations:^{
        _thumbButton.center = CGPointMake(pointX, CGRectGetHeight(self.bounds) / 2.0);
    } completion:^(BOOL finished) {
        if (self.sliderValueBlock) {
            self.sliderValueBlock(index);
        }
    }];
}

#pragma mark - Gesture
- (void)handlePan:(UIPanGestureRecognizer*)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:self];
        CGPoint newCenter = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y);
        
        if (newCenter.x >= 0 && newCenter.x <= CGRectGetWidth(self.bounds)) {
            recognizer.view.center = newCenter;
            [recognizer setTranslation:CGPointZero inView:self];
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        NSInteger index = [self getIndexInConditionArray:recognizer.view.center.x];
        
        [self animateToIndex:index];
    }
}

#pragma mark - setters and getters
- (void)setLocationArray:(NSArray *)locationArray {
    _locationArray = locationArray;
    
    _thumbButton.center = CGPointMake([_locationArray[0] floatValue], CGRectGetHeight(self.bounds) / 2.0);
}

- (void)setThumbImageString:(NSString *)thumbImageString {
    UIImage *image = [UIImage imageNamed:thumbImageString];
    
    [_thumbButton setImage:image forState:UIControlStateNormal];
    [_thumbButton setSize:CGSizeMake(image.size.width + 20, CGRectGetHeight(self.bounds))];
    
    // 设置背景图片的位置
    [_trackImageView setY:(CGRectGetHeight(self.bounds) - CGRectGetHeight(_trackImageView.bounds)) / 2.0];
}

- (UIButton*)thumbButton {
    if (!_thumbButton) {
        _thumbButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _thumbButton.frame = CGRectZero;
        [_thumbButton setAdjustsImageWhenHighlighted:NO];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_thumbButton addGestureRecognizer:panGesture];
    }
    return _thumbButton;
}

- (UIImageView*)trackImageView {
    if (!_trackImageView) {
        UIImage *image = [UIImage imageNamed:@"dashboard_hsilder_backgroudImage"];
        image = [image stretchableImageWithLeftCapWidth:floorf(image.size.width/2) topCapHeight:floorf(image.size.height/2)];
        _trackImageView = [[UIImageView alloc] initWithImage:image];
        _trackImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), image.size.height);
        
    }
    return _trackImageView;
}

@end
