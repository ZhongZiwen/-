//
//  SKTCustomTitleView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SKTCustomTitleView.h"
#import "NSString+Common.h"

@interface SKTCustomTitleView ()

@property (nonatomic, copy) AnimateSmartViewBlock aBlock;
@property (nonatomic, copy) CustomTitleViewTapBlock cBlock;
@property (nonatomic, weak) UILabel *m_label;
@property (nonatomic, weak) UIImageView *m_imageView;
@end

@implementation SKTCustomTitleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        _isShow = NO;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds)-160)/2.0, 0, 160, CGRectGetHeight(self.bounds))];
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _m_label = label;
        
        UIImage *image = [UIImage imageNamed:@"menu_selecter_arrow"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, (CGRectGetHeight(self.bounds)-image.size.height)/2.0, image.size.width, image.size.height);
        [self addSubview:imageView];
        _m_imageView = imageView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenuTableView)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setTitleString:(NSString *)titleString {
    
    _titleString = titleString;
    
    CGFloat width = [titleString getWidthWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(self.bounds))];
    
    _m_label.text = titleString;
    CGRect frame = _m_imageView.frame;
    if (width >= CGRectGetWidth(_m_label.bounds)) {
        frame.origin.x = _m_label.frame.origin.x + _m_label.frame.size.width+8;
        _m_imageView.frame = frame;
    }else {
        frame.origin.x = _m_label.frame.origin.x + _m_label.frame.size.width - (CGRectGetWidth(_m_label.bounds)-width)/2.0 + 8;
        _m_imageView.frame = frame;
    }
}

- (void)setIsShow:(BOOL)isShow {
    _isShow = isShow;
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
    [UIView animateWithDuration:0.2 animations:^{
        [_m_imageView setTransform:transform];
    }];
}

- (void)animateSmartViewWithBlock:(AnimateSmartViewBlock)block andTapBlock:(CustomTitleViewTapBlock)cBlock {
    _aBlock = block;
    _cBlock = cBlock;
}

- (void)showMenuTableView {
    if (!_isShow) { // 未显示
        _isShow = YES;
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.2 animations:^{
            [_m_imageView setTransform:transform];
        }];
    }else{  // 已经显示
        _isShow = NO;
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        [UIView animateWithDuration:0.2 animations:^{
            [_m_imageView setTransform:transform];
        }];
    }
    
    if (self.cBlock) {
        self.cBlock();
    }
    
    if (self.aBlock) {
        self.aBlock(_isShow);
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
