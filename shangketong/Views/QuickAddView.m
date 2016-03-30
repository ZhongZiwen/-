//
//  QuickAddView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "QuickAddView.h"
#import <POP.h>
#import "Quick.h"

#define kSize_ImageView     64*2
#define kLeftWidth_ImageView    (2 * CGRectGetWidth(self.bounds)-2*kSize_ImageView)/3.0

@interface QuickAddView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (assign, nonatomic) CGFloat size_imageView;   // 图片的直径
@property (assign, nonatomic) CGFloat left;             // 距离视图左边宽度
@property (assign, nonatomic) CGFloat top;              // 距离视图顶部宽度
@property (assign, nonatomic) CGFloat topBottom;        // 上下的间距
@property (assign, nonatomic) CGFloat leftRight;        // 左右的间距
@property (assign, nonatomic) CGFloat buttonBottom;
@property (assign, nonatomic) CGFloat titleHeight;
@property (assign, nonatomic) CGFloat titleFont;
@end

@implementation QuickAddView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.backgroundView];
    }
    return self;
}

#pragma mark - touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([touch.view isKindOfClass:[UIImageView class]]) {
        [self scaleToBig:touch.view];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([touch.view isKindOfClass:[UIImageView class]]) {
        [self scaleToDefault:touch.view];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([touch.view isKindOfClass:[UIImageView class]]) {
        [self scaleToDefault:touch.view];
    }
}

#pragma mark - event response
- (void)imageViewClick:(UITapGestureRecognizer*)sender {
    UIImageView *imageView = (UIImageView*)sender.view;
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    for (Quick *tempItem in _sourceArray) {
        if ([tempItem.isSelected isEqualToNumber:@1]) {
            [tempArray addObject:tempItem];
        }
    }
    Quick *lastItem = [[Quick alloc] init];
    lastItem.imageString = @"setting";
    lastItem.titleString = @"设置";
    [tempArray addObject:lastItem];
    Quick *quick = tempArray[imageView.tag];
    if (self.tapClickBlock) {
        self.tapClickBlock(quick.titleString);
    }
    [self scaleToDefault:imageView];
}

#pragma mark - public method
- (void)popAnimationShow {
    self.alpha = 1.0;
    _backgroundView.hidden = NO;
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.5, 0.5)];
    scaleAnimation.springBounciness = 8.f;
    [_backgroundView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

- (void)popAnimationDismiss {
    
    __weak typeof(self) weak_self = self;
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    animation.fromValue = @1;
    animation.toValue = @0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.duration = 0.5f;
    animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        [weak_self scaleToDefault:weak_self.backgroundView];
        [weak_self removeFromSuperview];
    };
    [self pop_addAnimation:animation forKey:@"easeOut"];
}

#pragma mark - private method
- (void)scaleToBig:(UIView*)view {
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.1f, 1.1f)];
    [view.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSmallAnimation"];
}

- (void)scaleToDefault:(UIView*)view {
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    [view.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleDefaultAnimation"];
}

#pragma mark - setters and getters
- (void)setSourceArray:(NSMutableArray *)sourceArray {
    _sourceArray = sourceArray;
    
    if (kDevice_Is_iPhone6Plus) {
        _size_imageView = 83.0f;
        _left = 83.0f;
        _top = 117.0f;
        _topBottom = 70.0f;
        _leftRight = 83.0f;
        _buttonBottom = 47.0f;
        _titleHeight = 30;
        _titleFont = 18;
    }
    else if (kDevice_Is_iPhone6) {
        _size_imageView = 75.0f;
        _left = 75.0f;
        _top = 107.0f;
        _topBottom = 73.0f;
        _leftRight = 75.0f;
        _titleHeight = 20;
        _buttonBottom = 48.0f;
        _titleFont = 16;
    }
    else if (kDevice_Is_iPhone5) {
        _size_imageView = 64.0f;
        _left = 64.0f;
        _top = 90.0f;
        _topBottom = 65.0f;
        _leftRight = 65.0f;
        _buttonBottom = 48.0f;
        _titleHeight = 20;
        _titleFont = 14;
    }
    else {
        _size_imageView = 64.0f;
        _left = 64.0f;
        _top = 57.0f;
        _topBottom = 60.0f;
        _leftRight = 65.0f;
        _buttonBottom = 35.0f;
        _titleHeight = 20;
        _titleFont = 14;
    }
    
    
    for (UIView *subView in _backgroundView.subviews) {
        [subView removeFromSuperview];
    }
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    for (Quick *tempItem in _sourceArray) {
        if ([tempItem.isSelected isEqualToNumber:@1]) {
            [tempArray addObject:tempItem];
        }
    }
    Quick *lastItem = [[Quick alloc] init];
    lastItem.imageString = @"setting";
    lastItem.titleString = @"设置";
    [tempArray addObject:lastItem];
    
    for (int i = 0; i < tempArray.count; i ++) {
        
        Quick *quick = tempArray[i];
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"today_quick_add_%@", quick.imageString]];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView setWidth:_size_imageView * 2];
        [imageView setHeight:_size_imageView * 2];
        [imageView setX:2 * _left + (_size_imageView * 2 + _leftRight * 2) * (i % 2)];
        [imageView setY:2 * _top + (_size_imageView * 2 + _topBottom * 2) * (i / 2)];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClick:)];
        [imageView addGestureRecognizer:tap];
        [_backgroundView addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setWidth:(_size_imageView + _size_imageView / 2.0) * 2];
        [titleLabel setHeight:_titleHeight * 2];
        [titleLabel setCenterX:CGRectGetMidX(imageView.frame)];
        [titleLabel setY:CGRectGetMaxY(imageView.frame) + 20];
        titleLabel.textColor = [UIColor colorWithHexString:@"0x8899a6"];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:_titleFont * 2];
        titleLabel.text = quick.titleString;
        [_backgroundView addSubview:titleLabel];
    }
    
    // 关闭
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setWidth:64 * 2];
    [button setHeight:_titleHeight * 2];
    [button setCenterX:kScreen_Width];
    [button setY:CGRectGetHeight(_backgroundView.bounds) - 2 * _buttonBottom - CGRectGetHeight(button.bounds)];
    button.titleLabel.font = [UIFont systemFontOfSize:_titleFont * 2];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"0x8899a6"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(popAnimationDismiss) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:button];
}

- (UIView*)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width*2, kScreen_Height*2)];
        _backgroundView.center = CGPointMake(kScreen_Width/2.0, kScreen_Height/2.0);
        _backgroundView.hidden = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popAnimationDismiss)];
        [_backgroundView addGestureRecognizer:tap];
    }
    return _backgroundView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
