//
//  InfoPopView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "InfoPopView.h"
#import "NSString+Common.h"
#import "UIView+Common.h"

#define kTitleFont          [UIFont systemFontOfSize:14]
#define kDetailFont         [UIFont systemFontOfSize:12]

@interface InfoPopView ()

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, assign) CGFloat sizeWidth;
@property (nonatomic, assign) CGFloat sizeHeight;

@property (nonatomic, strong) UIButton *handerView;
@end

@implementation InfoPopView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0f];
        _sizeWidth = 0;
        _sizeHeight = 10;
        
        [self addSubview:self.lineView];
    }
    return self;
}

- (void)layoutSubviews {
    
    [self setX:kScreen_Width - 10 - 37 - 5 - _sizeWidth - 25];
    [self setY:20];
    [self setSize:CGSizeMake(_sizeWidth + 25, _sizeHeight)];
    
    [_lineView setWidth:_sizeWidth];
    
    UIImage *bubbleImage = [UIImage imageNamed:@"Dashboard_infoView"];
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithFrame:self.frame];
    [bubbleImageView setImage:[bubbleImage stretchableImageWithLeftCapWidth:floorf(bubbleImage.size.width/2) topCapHeight:floorf(bubbleImage.size.height/2 + 5)]];
    
    CALayer *layer = bubbleImageView.layer;
    layer.frame = (CGRect){{0,0},bubbleImageView.layer.frame.size};
    self.layer.mask = layer;
    
    [super layoutSubviews];
}

#pragma event response
- (void)dismiss
{
    [UIView animateWithDuration:0.2 delay:0.f options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.transform = CGAffineTransformMakeScale(0.000001, 0.000001);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            [_handerView removeFromSuperview];
            self.transform = CGAffineTransformIdentity;
        }
    }];
}

#pragma mark - Public method
- (void)showInView:(UIView *)view {

    [view.superview addSubview:self.handerView];
    _handerView.frame = view.superview.frame;
    
    self.transform = CGAffineTransformMakeScale(0, 0);
    self.layer.anchorPoint = CGPointMake(1, 0.1);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.4 delay:0.f usingSpringWithDamping:0.6 initialSpringVelocity:1.5 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL completed){

    }];
}

- (UILabel*)textLabel {
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.numberOfLines = 0;
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    return textLabel;
}

#pragma mark - setters and getters
- (void)setTitleString:(NSString *)titleString {
    CGSize size = [titleString getSizeWithFont:kTitleFont constrainedToSize:CGSizeMake(_maxWidth - 25, MAXFLOAT)];
    if (size.width < _maxWidth - 25) {
        if (_sizeWidth < size.width) {
            _sizeWidth = size.width;
        }
    }else {
        _sizeWidth = _maxWidth - 25;
    }
    
    UILabel *titleLabel = [self textLabel];
    titleLabel.frame = CGRectMake(10, _sizeHeight, _sizeWidth, size.height);
    titleLabel.font = kTitleFont;
    titleLabel.text = titleString;
    [self addSubview:titleLabel];
    
    _sizeHeight += size.height;
}

- (void)setDetailArray:(NSArray *)detailArray {
    if (detailArray.count) {
        [_lineView setY:_sizeHeight + 10];
        _sizeHeight += 20;
    }
    
    for (NSDictionary *dict in detailArray) {
        CGSize size = [dict[@"des"] getSizeWithFont:kDetailFont constrainedToSize:CGSizeMake(_maxWidth - 25, MAXFLOAT)];
        if (size.width < _maxWidth - 25) {
            if (_sizeWidth < size.width) {
                _sizeWidth = size.width;
            }
        }else {
            _sizeWidth = _maxWidth - 25;
        }
        
        UILabel *detailLabel = [self textLabel];
        detailLabel.frame = CGRectMake(10, _sizeHeight, _sizeWidth, size.height);
        detailLabel.font = kDetailFont;
        detailLabel.text = dict[@"des"];
        [self addSubview:detailLabel];
        
        _sizeHeight += size.height;
    }
    
    _sizeHeight += 10;
}

- (UIView*)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 0, 0.5)];
        _lineView.backgroundColor = [UIColor whiteColor];
    }
    return _lineView;
}

- (UIButton*)handerView {
    if (!_handerView) {
        _handerView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_handerView setBackgroundColor:[UIColor clearColor]];
        [_handerView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _handerView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
