//
//  EmotionKeyboardView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EmotionKeyboardView.h"
#import "EmotionTabBar.h"
#import "EmotionPageView.h"

#import "UIColor+expanded.h"

@interface EmotionKeyboardView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) EmotionTabBar *emotionTabBar;
@property (nonatomic, strong) NSDictionary *emotionSourceDict;
@property (nonatomic, copy) NSString *category;             // 表情类别
@end

@implementation EmotionKeyboardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        
        [self addSubview:self.emotionTabBar];
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)layoutSubviews {
    
    // 获取某类别表情显示的页数
    NSUInteger numberOfPages = 0;
    if (self.emotionSourceDict.allKeys.count % 20 == 0) {
        numberOfPages = self.emotionSourceDict.allKeys.count / 20;
    }else {
        numberOfPages = self.emotionSourceDict.allKeys.count / 20 + 1;
    }
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = numberOfPages;
    self.pageControl.center = CGPointMake(kScreen_Width / 2.0, CGRectGetHeight(_scrollView.bounds) + 15);
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.scrollView.contentSize = CGSizeMake(kScreen_Width * numberOfPages, CGRectGetHeight(self.bounds)- CGRectGetHeight(self.emotionTabBar.bounds) - 30);
    
    // 初始化emotionPageView，并添加到scrollView
    for (int i = 0; i < numberOfPages; i ++) {
        EmotionPageView *emotionPageView = [[EmotionPageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.scrollView.bounds) * i, 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds)) andEmotionSource:self.emotionSourceDict andPageIndex:i];
        emotionPageView.useEmotionBlock = ^(NSString *emotionStr) {
            [self.delegate emotionKeyBoardView:self didUseEmotion:emotionStr];
        };
        emotionPageView.deleteEmotionBlock = ^{
            [self.delegate emotionKeyBoardViewDidPressBackSpace:self];
        };
        [self.scrollView addSubview:emotionPageView];
    }
}

#pragma mark - Private Method

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.pageControl.currentPage == newPageNumber) {
        return;
    }
    self.pageControl.currentPage = newPageNumber;
}

#pragma mark - setters and getters
- (void)setDataSource:(id<EmotionKeyboardViewDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    _dataSource = dataSource;
    
    // 获取表情数据源
    if ([_dataSource respondsToSelector:@selector(emotionKeyboardView:emotionSourceAtCategory:)]) {
        self.emotionSourceDict = [_dataSource emotionKeyboardView:self emotionSourceAtCategory:EmotionKeyboardViewCategoryImageQQ];
    }
}

- (UIScrollView*)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.emotionTabBar.bounds) - 30)];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl*)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:(CGFloat)90/255.0 green:(CGFloat)172/255.0 blue:(CGFloat)235/255.0 alpha:1.0f];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}

- (EmotionTabBar*)emotionTabBar {
    if (!_emotionTabBar) {
        __weak __block typeof(self) copy_self = self;
        _emotionTabBar = [[EmotionTabBar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 36, CGRectGetWidth(self.bounds), 36) andButtonImages:@[@"defineEmotionGroup"]];
        _emotionTabBar.selectedIndexChangedBlock = ^(NSInteger index) {
            copy_self.pageControl.currentPage = 0;
            [copy_self setNeedsLayout];
        };
        _emotionTabBar.sendButtonClickedBlock = ^{
            [copy_self.delegate emotionKeyBoardViewDidPressSendButton:copy_self];
        };
    }
    return _emotionTabBar;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
