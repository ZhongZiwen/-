//
//  WorkReportWorkResultHUD.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WRWorkResultHUD.h"
#import "UIView+Common.h"
#import "NSString+Common.h"

@interface WRWorkResultHUD ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *indicatorLabel;
@end

@implementation WRWorkResultHUD

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // 默认为14号字体
        _titleFont = [UIFont systemFontOfSize:14];
        // 默认为灰色
        _titleColor = [UIColor lightGrayColor];
        
        [self addSubview:self.indicatorView];
        [self addSubview:self.indicatorLabel];
    }
    return self;
}

- (void)startAnimationWith:(NSString *)string {
    CGFloat width = [string getWidthWithFont:_titleFont constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
    [_indicatorLabel setWidth:width];
    [_indicatorLabel setCenterX:CGRectGetWidth(self.bounds) / 2];
    [_indicatorLabel setCenterY:CGRectGetHeight(self.bounds) / 2];
    _indicatorLabel.text = string;
    
    [_indicatorView setX:_indicatorLabel.frame.origin.x - 20 - 10];
    [_indicatorView setCenterY:CGRectGetHeight(self.bounds) / 2];
    [_indicatorView startAnimating];
}

- (void)stopAnimationWith:(NSString *)string {
    
    [_indicatorView stopAnimating];
    
    if (string && [string length]) {
        CGFloat width = [string getWidthWithFont:_titleFont constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
        [_indicatorLabel setWidth:width];
        [_indicatorLabel setCenterX:CGRectGetWidth(self.bounds) / 2];
        [_indicatorLabel setCenterY:CGRectGetHeight(self.bounds) / 2];
        _indicatorLabel.text = string;
    }else {
        [self removeFromSuperview];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark setters and getters
- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    
    self.indicatorLabel.font = _titleFont;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    
    self.indicatorLabel.textColor = _titleColor;
    self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
}

- (UIActivityIndicatorView*)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

- (UILabel*)indicatorLabel {
    if (!_indicatorLabel) {
        _indicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        _indicatorLabel.font = _titleFont;
        _indicatorLabel.textColor = [UIColor lightGrayColor];
        _indicatorLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _indicatorLabel;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
