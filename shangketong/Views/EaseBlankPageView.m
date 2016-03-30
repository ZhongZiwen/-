//
//  EaseBlankPageView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EaseBlankPageView.h"

@interface EaseBlankPageView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *tipLabel;
@property (strong, nonatomic) UIButton *reloadButton;
@property (copy, nonatomic) void(^reloadButtonBlock)(id sender);
@end

@implementation EaseBlankPageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)configWithTitle:(NSString *)title hasData:(BOOL)hasData hasError:(BOOL)hasError reloadButtonBlock:(void (^)(id))block {
    if (hasData) {
        [self removeFromSuperview];
        return;
    }
    
    self.alpha = 1.0f;
    
    // 图片
    if (!_imageView) {
        UIImage *image = [UIImage imageNamed:@"list_empty"];
        _imageView = [[UIImageView alloc] initWithImage:image];
        [_imageView setWidth:image.size.width];
        [_imageView setHeight:image.size.height];
        [_imageView setCenterX:kScreen_Width / 2];
        [_imageView setCenterY:CGRectGetHeight(self.bounds) * 3 / 8.0];
        [self addSubview:_imageView];
    }
    
    // 文字
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        [_tipLabel setY:CGRectGetMaxY(_imageView.frame)];
        [_tipLabel setWidth:kScreen_Width];
        [_tipLabel setHeight:30];
        _tipLabel.font = [UIFont systemFontOfSize:15];
        _tipLabel.textColor = [UIColor lightGrayColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_tipLabel];
    }
    
    _reloadButtonBlock = nil;
    
    _tipLabel.text = title;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
