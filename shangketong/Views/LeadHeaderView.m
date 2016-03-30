//
//  LeadHeaderView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LeadHeaderView.h"
#import "CRMDetail.h"

@interface LeadHeaderView ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *oneView;
@property (strong, nonatomic) UIView *twoView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *questionButton;
@property (strong, nonatomic) UIButton *phoneButton;
@property (strong, nonatomic) UIButton *emailButton;
@property (strong, nonatomic) UIButton *positionButton;
@property (strong, nonatomic) UIButton *stateButton;

@property (strong, nonatomic) CRMDetail *item;
@end

@implementation LeadHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)configWithModel:(CRMDetail *)item {
    
    _item = item;
    
    _nameLabel.text = item.name;
    
    [_phoneButton setImage:[UIImage imageNamed:(item.phone || item.mobile ? @"tel" : @"tel_disable")] forState:UIControlStateNormal];
    [_phoneButton setEnabled:item.phone || item.mobile ? YES : NO];
    
    [_emailButton setImage:[UIImage imageNamed:(item.email ? @"mail" : @"mail_disable")] forState:UIControlStateNormal];
    [_emailButton setEnabled:item.email ? YES : NO];
    
    [_positionButton setImage:[UIImage imageNamed:(item.position ? @"location" : @"location_disable")] forState:UIControlStateNormal];
    [_positionButton setEnabled:item.position ? YES : NO];
    
    NSString *stateString = [NSString stringWithFormat:@" 跟进状态：%@ >", item.followState.value];
    CGFloat width = [stateString getWidthWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 30)];
    [_stateButton setWidth:width + 44];
    [_stateButton setCenterX:kScreen_Width / 2];
    [_stateButton setImage:[UIImage imageNamed:@"status"] forState:UIControlStateNormal];
    [_stateButton setTitle:stateString forState:UIControlStateNormal];
}

#pragma mark - event response
- (void)phoneButtonPress {
    if (self.phoneBtnClickedBlock) {
        self.phoneBtnClickedBlock();
    }
}

- (void)emailButtonPress {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *sendAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"发送邮件给%@", _item.email] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.emailBtnClickedBlock) {
            self.emailBtnClickedBlock();
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:sendAction];
    [kKeyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)positionButtonPress {
    if (self.positionBtnClickedBlock) {
        self.positionBtnClickedBlock();
    }
}

- (void)stateButtonPress {
    if (self.stateBtnClickedBlock) {
        self.stateBtnClickedBlock();
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 根据当前的x坐标和宽度计算出当前页数
    _pageControl.currentPage = (int)scrollView.contentOffset.x/kScreen_Width;
}

#pragma mark - setters and getters
- (UIScrollView*)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        [_scrollView setWidth:CGRectGetWidth(self.bounds)];
        [_scrollView setHeight:CGRectGetHeight(self.bounds)];
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        [_scrollView addSubview:self.oneView];
        [_scrollView addSubview:self.twoView];
        [_scrollView setContentSize:CGSizeMake(2 * kScreen_Width, CGRectGetHeight(self.bounds))];
    }
    return _scrollView;
}

- (UIPageControl*)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = 2;
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.95 alpha:0.8];
        [_pageControl sizeToFit];
        [_pageControl setCenterX:CGRectGetMidX(self.frame)];
        [_pageControl setY:CGRectGetHeight(self.bounds) - CGRectGetHeight(_pageControl.bounds)];
    }
    return _pageControl;
}

- (UIView*)oneView {
    if (!_oneView) {
        _oneView = [[UIView alloc] init];
        [_oneView setWidth:kScreen_Width];
        [_oneView setHeight:CGRectGetHeight(self.bounds)];
        
        [_oneView addSubview:self.nameLabel];
        [_oneView addSubview:self.phoneButton];
        [_oneView addSubview:self.emailButton];
        [_oneView addSubview:self.positionButton];
    }
    return _oneView;
}

- (UIView*)twoView {
    if (!_twoView) {
        _twoView = [[UIView alloc] init];
        [_twoView setX:kScreen_Width];
        [_twoView setWidth:kScreen_Width];
        [_twoView setHeight:CGRectGetHeight(self.bounds)];
        
        [_twoView addSubview:self.stateButton];
    }
    return _twoView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setWidth:kScreen_Width - 30];
        [_nameLabel setHeight:20];
        [_nameLabel setCenterX:kScreen_Width / 2];
        [_nameLabel setCenterY:44];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UIButton*)phoneButton {
    if (!_phoneButton) {
        UIImage *image = [UIImage imageNamed:@"tel_disable"];
        _phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_phoneButton setWidth:image.size.width];
        [_phoneButton setHeight:image.size.height];
        [_phoneButton setCenterY:CGRectGetHeight(self.bounds) - 50];
        [_phoneButton setCenterX:kScreen_Width / 2 - kScreen_Width / 4];
        [_phoneButton addTarget:self action:@selector(phoneButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _phoneButton;
}

- (UIButton*)emailButton {
    if (!_emailButton) {
        _emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emailButton setY:CGRectGetMinY(_phoneButton.frame)];
        [_emailButton setWidth:CGRectGetWidth(_phoneButton.bounds)];
        [_emailButton setHeight:CGRectGetHeight(_phoneButton.bounds)];
        [_emailButton setCenterX:kScreen_Width / 2.0];
        [_emailButton addTarget:self action:@selector(emailButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emailButton;
}

- (UIButton*)positionButton {
    if (!_positionButton) {
        _positionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_positionButton setY:CGRectGetMinY(_phoneButton.frame)];
        [_positionButton setWidth:CGRectGetWidth(_phoneButton.bounds)];
        [_positionButton setHeight:CGRectGetHeight(_phoneButton.bounds)];
        [_positionButton setCenterX:kScreen_Width / 2 + kScreen_Width / 4];
        [_positionButton addTarget:self action:@selector(positionButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _positionButton;
}

- (UIButton*)stateButton {
    if (!_stateButton) {
        _stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stateButton setHeight:30];
        [_stateButton setCenterY:CGRectGetHeight(self.bounds) / 2];
        [_stateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _stateButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_stateButton addTarget:self action:@selector(stateButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stateButton;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
