//
//  CirclePlayView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/28.
//  Copyright © 2015年 sungoin. All rights reserved.
//

#import "CirclePlayView.h"
#import <POP/POP.h>

@interface CirclePlayView ()

@property (strong, nonatomic) CAShapeLayer *circleLayer;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *label;
@end

@implementation CirclePlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *label = [[UILabel alloc] init];
        [label setWidth:CGRectGetWidth(self.bounds)];
        [label setHeight:20];
        [label setCenterY:CGRectGetHeight(self.bounds) / 2];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _label = label;
        
        CGFloat lineWidth = 2.f;
        CGFloat radius = CGRectGetWidth(self.bounds)/2 - lineWidth/2;
        self.circleLayer = [CAShapeLayer layer];
        CGRect rect = CGRectMake(lineWidth/2, lineWidth/2, radius * 2, radius * 2);
        self.circleLayer.path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath;
        self.circleLayer.strokeColor = [UIColor colorWithRGBHex:0x2faeea].CGColor;
        self.circleLayer.fillColor = nil;
        self.circleLayer.lineWidth = lineWidth;
        self.circleLayer.lineCap = kCALineCapRound;
        self.circleLayer.lineJoin = kCALineJoinRound;
        self.circleLayer.strokeEnd = 0;
        [self.layer addSublayer:self.circleLayer];
    }
    return self;
}

- (void)setPlayState:(AudioPlayViewState)playState {
    [super setPlayState:playState];
    if (playState == AudioPlayViewStatePlaying) {
        _label.text = @"停止";
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = _duration;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.f];
        [self.circleLayer addAnimation:pathAnimation forKey:nil];
    }
    else {
        _label.text = @"播放";
        [self.circleLayer removeAllAnimations];
        self.circleLayer.strokeEnd = 0;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
