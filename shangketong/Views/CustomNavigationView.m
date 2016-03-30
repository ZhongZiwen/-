//
//  CustomNavigationView.m
//  shangketong
//
//  Created by sungoin-zbs on 16/3/9.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "CustomNavigationView.h"
#import "WRWorkResultHUD.h"

@interface CustomNavigationView ()

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *rightButton;
@property (strong, nonatomic) WRWorkResultHUD *hud;
@end

@implementation CustomNavigationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [[UIColor colorWithHexString:@"0x2e3440"] colorWithAlphaComponent:0];
        
        [self addSubview:self.rightButton];
        [self addSubview:self.titleLabel];
        [self addSubview:self.backButton];
        [self addSubview:self.hud];
    }
    return self;
}

#pragma mark - event response
- (void)rightButtonPress {
    if (self.rightButtonClickedBlock) {
        self.rightButtonClickedBlock();
    }
}

- (void)backButtonPress {
    if (self.backButtonClickedBlock) {
        self.backButtonClickedBlock();
    }
}

#pragma mark - public method
- (void)startAnimation {
    _titleLabel.hidden = YES;
    _hud.hidden = NO;
    [_hud startAnimationWith:@"加载中"];
}

- (void)stopAnimation {
    _titleLabel.hidden = NO;
    _hud.hidden = YES;
    [_hud stopAnimationWith:@"加载结束"];
}

#pragma mark - setters and getters
- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    
    self.titleLabel.text = _titleString;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton setWidth:47];
        [_rightButton setHeight:30];
        [_rightButton setX:kScreen_Width - CGRectGetWidth(_rightButton.bounds) - 5];
        [_rightButton setCenterY:42];
        [_rightButton setImage:[UIImage imageNamed:@"menu_showMore_active"] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setWidth:200];
        [_titleLabel setHeight:27];
        [_titleLabel setCenterX:kScreen_Width / 2.0];
        [_titleLabel setCenterY:CGRectGetMidY(_rightButton.frame)];
        _titleLabel.font = [UIFont systemFontOfSize:19];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setX:5];
        [_backButton setWidth:47];
        [_backButton setHeight:30];
        [_backButton setCenterY:CGRectGetMidY(_rightButton.frame)];
        [_backButton setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        _backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, [UIImage imageNamed:@"nav_back"].size.width);
        [_backButton addTarget:self action:@selector(backButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (WRWorkResultHUD *)hud {
    if (!_hud) {
        _hud = [[WRWorkResultHUD alloc] initWithFrame:CGRectMake(0, 0, 200, 27)];
        [_hud setCenterX:kScreen_Width / 2.0];
        [_hud setCenterY:CGRectGetMidY(_rightButton.frame)];
        _hud.titleFont = [UIFont systemFontOfSize:19];
        _hud.titleColor = [UIColor whiteColor];
    }
    return _hud;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
