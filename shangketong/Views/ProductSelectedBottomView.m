//
//  ProductSelectedBottomView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ProductSelectedBottomView.h"

@interface ProductSelectedBottomView ()

@property (strong, nonatomic) UIButton *bottomButton;
@property (strong, nonatomic) UIButton *confireButton;
@property (strong, nonatomic) UILabel *bottomLabel;
@property (strong, nonatomic) UILabel *countLabel;
@end

@implementation ProductSelectedBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kView_BG_Color;
        [self addLineUp:YES andDown:NO];
        
        [self addSubview:self.bottomButton];
        [self addSubview:self.confireButton];
        [self addSubview:self.bottomLabel];
        [self addSubview:self.countLabel];
    }
    return self;
}

- (void)updateCountLabelWithCount:(NSInteger)count {
    
    _countLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
    _countLabel.text = [NSString stringWithFormat:@"%d", count ? : 0];
    
    [UIView animateWithDuration:0.3 animations:^{
        _countLabel.transform = CGAffineTransformMakeScale(1.125, 1.125);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _countLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:nil];
    }];
    
    if (count) {
        _confireButton.enabled = YES;
    }else {
        _confireButton.enabled = NO;
    }
}

#pragma mark - event response
- (void)bottomButtonPress {
    if (self.bottomBtnPressBlock) {
        self.bottomBtnPressBlock();
    }
}

- (void)confirmButtonPress {
    if (self.confireBtnPressBlock) {
        self.confireBtnPressBlock();
    }
}

#pragma mark - setters and getters
- (UIButton*)bottomButton {
    if (!_bottomButton) {
        _bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomButton.frame = self.bounds;
        [_bottomButton addTarget:self action:@selector(bottomButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomButton;
}

- (UILabel*)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        [_bottomLabel setX:15];
        [_bottomLabel setWidth:94];
        [_bottomLabel setHeight:20];
        _bottomLabel.font = [UIFont systemFontOfSize:16];
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        _bottomLabel.text = @"已选择产品:";
        [_bottomLabel setCenterY:CGRectGetHeight(self.bounds) / 2.0];
    }
    return _bottomLabel;
}

- (UILabel*)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        [_countLabel setX:CGRectGetMaxX(_bottomLabel.frame)];
        [_countLabel setWidth:24];
        [_countLabel setHeight:24];
        [_countLabel setCenterY:CGRectGetHeight(self.bounds) / 2.0];
        _countLabel.backgroundColor = [UIColor colorWithRed:(CGFloat)34/255.0f green:(CGFloat)192/255.f blue:(CGFloat)100/255.f alpha:1.f];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = [UIFont systemFontOfSize:14];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.text = @"0";
        [_countLabel doCircleFrame];
    }
    return _countLabel;
}

- (UIButton*)confireButton {
    if (!_confireButton) {
        _confireButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confireButton setX:kScreen_Width - 54];
        [_confireButton setWidth:54];
        [_confireButton setHeight:CGRectGetHeight(self.bounds)];
        _confireButton.enabled = NO;
        _confireButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_confireButton setTitleColor:[[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:1.0]
                                forState:UIControlStateNormal];
        [_confireButton setTitleColor:[[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:0.3]
                                forState:UIControlStateDisabled];
        [_confireButton setTitle:@"完成" forState:UIControlStateNormal];
        [_confireButton addTarget:self action:@selector(confirmButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confireButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
