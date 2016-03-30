//
//  ForwardToolView.m
//  shangketong
//
//  Created by sungoin-zjp on 15-8-6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ForwardToolView.h"
#import "UIView+Common.h"
#import "NSString+Common.h"

#define kBGButtonColor [UIColor colorWithRed:(CGFloat)245/255.0 green:(CGFloat)245/255.0 blue:(CGFloat)245/255.0 alpha:1.0f]

@interface ForwardToolView ()

@property (nonatomic, strong) UIButton *privateBtn;
@property (nonatomic, strong) UIButton *atBtn;
@end

@implementation ForwardToolView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 44, CGRectGetWidth(self.bounds), 44)];
        backgroundView.backgroundColor = kBGButtonColor;
        [backgroundView addLineUp:YES andDown:YES];
        [self addSubview:backgroundView];
        
        [backgroundView addSubview:self.privateBtn];
        [backgroundView addSubview:self.atBtn];
        
    }
    return self;
}

#pragma mark - event response


- (void)privateBtnPress {
    if (self.privateBlock) {
        self.privateBlock();
    }
}

- (void)atBtnPress {
    if (self.atBlock) {
        self.atBlock();
    }
}


- (void)setPrivateBtnTitle:(NSString *)privateBtnTitle {
    if ([privateBtnTitle isEqualToString:@"公开"]) {
        UIImage *image = [UIImage imageNamed:@"feed_post_public"];
        [_privateBtn setImage:image forState:UIControlStateNormal];
        [_privateBtn setTitle:privateBtnTitle forState:UIControlStateNormal];
        
        CGFloat strWidth = [privateBtnTitle getWidthWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13] constrainedToSize:CGSizeMake(MAXFLOAT, 24)];
        
        [_privateBtn setWidth:strWidth + image.size.width + 20];
    }else {
        UIImage *image = [UIImage imageNamed:@"feed_post_group"];
        [_privateBtn setImage:image forState:UIControlStateNormal];
        [_privateBtn setTitle:privateBtnTitle forState:UIControlStateNormal];
        
        CGFloat strWidth = [privateBtnTitle getWidthWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13] constrainedToSize:CGSizeMake(MAXFLOAT, 24)];
        
        [_privateBtn setWidth:strWidth + image.size.width + 20];
    }
    
}

- (UIButton*)atBtn {
    if (!_atBtn) {
        _atBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _atBtn.frame = CGRectMake(30, 7, 30, 30);
        [_atBtn setImage:[UIImage imageNamed:@"acitvity_at.png"] forState:UIControlStateNormal];
        [_atBtn setImage:[UIImage imageNamed:@"acitvity_at_press"] forState:UIControlStateHighlighted];
        [_atBtn addTarget:self action:@selector(atBtnPress) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _atBtn;
}

- (UIButton*)privateBtn {
    if (!_privateBtn) {
        _privateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _privateBtn.frame = CGRectMake(90, 7, 30, 30);
        _privateBtn.backgroundColor = kBGButtonColor;
        _privateBtn.layer.cornerRadius = 6;
        _privateBtn.clipsToBounds = YES;
        _privateBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        [_privateBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_privateBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -4.0, 0.0, 0.0)];
        [_privateBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -4.0)];
        [_privateBtn addTarget:self action:@selector(privateBtnPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _privateBtn;
}

@end
