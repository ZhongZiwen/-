//
//  FilterSlider.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FilterSlider.h"

#define kTag_titleLabel 34534

@interface FilterSlider ()

@property (strong, nonatomic) UIButton *leftThumbView;
@property (strong, nonatomic) UIButton *rightThumbView;
@property (strong, nonatomic) UIImageView *trackImageViewNormal;
@property (strong, nonatomic) UIImageView *trackImageViewHighlighted;
@property (strong, nonatomic) UIImage *trackImageNormal;
@property (strong, nonatomic) UIImage *trackImageHighlighted;

@property (assign, nonatomic) BOOL leftThumbOn;
@property (assign, nonatomic) BOOL rightThumbOn;

@property (assign, nonatomic) NSInteger unit;
@property (copy, nonatomic) NSString *unitName;
@end

@implementation FilterSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        
        if (kDevice_Is_iPhone6Plus) {
            _trackImageNormal = [UIImage imageNamed:@"filter_slider_bg_w828"];
            _trackImageHighlighted = [UIImage imageNamed:@"filter_slider_cover_w828"];
        }else if (kDevice_Is_iPhone6) {
            _trackImageNormal = [UIImage imageNamed:@"filter_slider_bg_w750"];
            _trackImageHighlighted = [UIImage imageNamed:@"filter_slider_cover_w750"];
        }else {
            _trackImageNormal = [UIImage imageNamed:@"filter_slider_bg_w640"];
            _trackImageHighlighted = [UIImage imageNamed:@"filter_slider_cover_w640"];
        }

        [self addSubview:self.trackImageViewNormal];
        [self addSubview:self.trackImageViewHighlighted];
        [self addSubview:self.leftThumbView];
        [self addSubview:self.rightThumbView];
        
        _leftThumbOn = NO;
        _rightThumbOn = NO;
        
        NSArray *titleArray = @[@"0", @"1", @"3", @"5", @"8", @"不限"];
        CGFloat width = (CGRectGetWidth(_trackImageViewNormal.bounds) - CGRectGetHeight(_trackImageViewNormal.bounds)) / 5.0;
        for (int i = 0; i < titleArray.count; i ++) {
            UILabel *label = [[UILabel alloc] init];
            [label setWidth:30];
            [label setHeight:15];
            [label setCenterX:CGRectGetMinX(_trackImageViewNormal.frame) + CGRectGetHeight(_trackImageViewNormal.bounds) / 2 + width * i];
            [label setCenterY:17];
            label.tag = kTag_titleLabel + i;
            label.font = [UIFont systemFontOfSize:11];
            label.textColor = [UIColor iOS7lightBlueColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = titleArray[i];
            [self addSubview:label];
        }
    }
    return self;
}

- (void)configWithLeftValue:(NSInteger)leftValue rightValue:(NSInteger)rightValue {
    UILabel *label = (UILabel*)[self viewWithTag:kTag_titleLabel + leftValue];
    [_leftThumbView setCenterX:CGRectGetMidX(label.frame)];
    _leftValue = leftValue;
    _leftValueTitle = label.text;
    label = (UILabel*)[self viewWithTag:kTag_titleLabel + rightValue];
    [_rightThumbView setCenterX:CGRectGetMidX(label.frame)];
    _rightValue = rightValue;
    _rightValueTitle = label.text;
}

- (void)setId:(NSString *)id {
    switch ([id integerValue]) {
        case 0: {
            _unit = 1000;
            _unitName = @"千";
        }
            break;
        case 1: {
            _unit = 10000;
            _unitName = @"万";
        }
            break;
        case 2: {
            _unit = 100000;
            _unitName = @"十万";
        }
            break;
        case 3: {
            _unit = 1000000;
            _unitName = @"百万";
        }
            break;
        default:
            break;
    }
}

- (void)configValue {
    if (!_leftValue && _rightValue == 5) {
        _value = nil;
        _valueName = nil;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        return;
    }
    
    if (_rightValue == 5) {
        _value = [NSString stringWithFormat:@"%d", [_leftValueTitle integerValue] * _unit];
        _valueName = [NSString stringWithFormat:@"%@%@-%@", _leftValueTitle, _unitName, _rightValueTitle];
    }else if (_leftValue == 0) {
        _value = [NSString stringWithFormat:@"0,%d", [_rightValueTitle integerValue] * _unit];
        _valueName = [NSString stringWithFormat:@"0-%@%@", _rightValueTitle, _unitName];
    }else {
        _value = [NSString stringWithFormat:@"%d,%d", [_leftValueTitle integerValue] * _unit, [_rightValueTitle integerValue] * _unit];
        _valueName = [NSString stringWithFormat:@"%@%@-%@%@", _leftValueTitle, _unitName, _rightValueTitle, _unitName];
    }

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)leftHandlePan:(UIPanGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self];
        CGPoint newCenter = CGPointMake(gesture.view.center.x + translation.x, gesture.view.center.y);
        
        gesture.view.center = CGPointMake(MIN(MAX(CGRectGetMinX(_trackImageViewNormal.frame) + CGRectGetHeight(_trackImageViewNormal.bounds) / 2.0, newCenter.x), CGRectGetMidX(_rightThumbView.frame) - (CGRectGetWidth(_trackImageViewNormal.bounds) - CGRectGetHeight(_trackImageViewNormal.bounds)) / 5.0), newCenter.y);
        [self setNeedsDisplay];
        [gesture setTranslation:CGPointZero inView:self];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        _leftValue = [self getIndexInPositionWithCenterX:gesture.view.center.x];
        UILabel *label = (UILabel*)[self viewWithTag:kTag_titleLabel + _leftValue];
        _leftValueTitle = label.text;
        [UIView animateWithDuration:0.1 animations:^{
            [gesture.view setCenterX:label.center.x];
        } completion:^(BOOL finished) {
            [self setNeedsDisplay];
            
            [self configValue];
        }];
    }
}

- (void)rightHandlePan:(UIPanGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self];
        CGPoint newCenter = CGPointMake(gesture.view.center.x + translation.x, gesture.view.center.y);
        
        gesture.view.center = CGPointMake(MIN(MAX(CGRectGetMidX(_leftThumbView.frame) + (CGRectGetWidth(_trackImageViewNormal.bounds) - CGRectGetHeight(_trackImageViewNormal.bounds)) / 5.0, newCenter.x), CGRectGetMaxX(_trackImageViewNormal.frame) - CGRectGetHeight(_trackImageViewNormal.bounds) / 2.0), newCenter.y);
        [self setNeedsDisplay];
        [gesture setTranslation:CGPointZero inView:self];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        _rightValue = [self getIndexInPositionWithCenterX:gesture.view.center.x];
        UILabel *label = (UILabel*)[self viewWithTag:kTag_titleLabel + _rightValue];
        _rightValueTitle = label.text;
        [UIView animateWithDuration:0.1 animations:^{
            [gesture.view setCenterX:label.center.x];
        } completion:^(BOOL finished) {
            [self setNeedsDisplay];
            
            [self configValue];
        }];
    }
}

- (NSInteger)getIndexInPositionWithCenterX:(CGFloat)x {

    UILabel *label = (UILabel*)[self viewWithTag:kTag_titleLabel];
    CGFloat width = (CGRectGetWidth(_trackImageViewNormal.bounds) - CGRectGetHeight(_trackImageViewNormal.bounds)) / 5.0;
    return roundf((x - label.center.x) / width);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    CGFloat thumbMidXInHightTrack = CGRectGetMidX([self convertRect:_leftThumbView.frame toView:_trackImageViewNormal]);
//    CGRect maskRect = CGRectMake(0, 0, thumbMidXInHightTrack, CGRectGetHeight(_trackImageViewNormal.bounds));
//    
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path, nil, maskRect);
//    
//    [maskLayer setPath:path];
//    
//    CGPathRelease(path);
//    _trackImageViewHighlighted.layer.mask = maskLayer;
}

#pragma mark - setters and getters
- (UIImageView*)trackImageViewNormal {
    if (!_trackImageViewNormal) {
        _trackImageViewNormal = [[UIImageView alloc] initWithImage:_trackImageNormal];
        [_trackImageViewNormal setWidth:_trackImageNormal.size.width];
        [_trackImageViewNormal setHeight:_trackImageNormal.size.height];
        [_trackImageViewNormal setCenterX:CGRectGetWidth(self.bounds) / 2];
        [_trackImageViewNormal setCenterY:CGRectGetHeight(self.bounds) / 2 + 8];
    }
    return _trackImageViewNormal;
}

- (UIImageView*)trackImageViewHighlighted {
    if (!_trackImageViewHighlighted) {
        _trackImageViewHighlighted = [[UIImageView alloc] initWithImage:_trackImageHighlighted];
        [_trackImageViewHighlighted setWidth:_trackImageHighlighted.size.width];
        [_trackImageViewHighlighted setHeight:_trackImageHighlighted.size.height];
        [_trackImageViewHighlighted setCenterX:CGRectGetWidth(self.bounds) / 2];
        [_trackImageViewHighlighted setCenterY:CGRectGetHeight(self.bounds) / 2 + 8];
    }
    return _trackImageViewHighlighted;
}

- (UIButton*)leftThumbView {
    if (!_leftThumbView) {
        UIImage *image = [UIImage imageNamed:@"filter_slider_btn"];
        _leftThumbView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftThumbView setWidth:image.size.width + 15];
        [_leftThumbView setHeight:image.size.height + 15];
        [_leftThumbView setCenterY:CGRectGetMidY(_trackImageViewNormal.frame)];
        [_leftThumbView setAdjustsImageWhenHighlighted:NO];
        [_leftThumbView setImage:image forState:UIControlStateNormal];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftHandlePan:)];
        [_leftThumbView addGestureRecognizer:panGesture];
    }
    return _leftThumbView;
}

- (UIButton*)rightThumbView {
    if (!_rightThumbView) {
        UIImage *image = [UIImage imageNamed:@"filter_slider_btn"];
        _rightThumbView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightThumbView setWidth:image.size.width + 15];
        [_rightThumbView setHeight:image.size.height + 15];
        [_rightThumbView setCenterY:CGRectGetMidY(_trackImageViewNormal.frame)];
        [_rightThumbView setAdjustsImageWhenHighlighted:NO];
        [_rightThumbView setImage:image forState:UIControlStateNormal];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightHandlePan:)];
        [_rightThumbView addGestureRecognizer:panGesture];
    }
    return _rightThumbView;
}
@end
