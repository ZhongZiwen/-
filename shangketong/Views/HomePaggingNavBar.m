//
//  HomePaggingNavBar.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "HomePaggingNavBar.h"
#import "UIView+Common.h"

#define kLabelTag 1000

@interface HomePaggingNavBar ()

@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation HomePaggingNavBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)setTitlesArray:(NSArray *)titlesArray
{
    if (!titlesArray.count) {
        return;
    }
    
    _titlesArray = titlesArray;
    
    [titlesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100 * idx, 8, CGRectGetWidth(self.bounds), 20)];
        label.tag = kLabelTag + idx;
        label.font = [[UINavigationBar appearance].titleTextAttributes objectForKey:NSFontAttributeName];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.text = (NSString*)obj;
        label.alpha = (_currentPage == idx ? 1.0f : 0.0f);
        [self addSubview:label];
    }];
    
    _pageControl.numberOfPages = titlesArray.count;
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    _pageControl.currentPage = currentPage;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    _contentOffset = contentOffset;
    
    CGFloat x_offset = contentOffset.x;
    
    [_titlesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UILabel *titleLabel = (UILabel*)[self viewWithTag:kLabelTag + idx];
        [titleLabel setX:100 * idx - x_offset / 3.2];
        
        // alpha
        CGFloat alpha;
        if (x_offset < kScreen_Width * idx) {
            alpha = (x_offset - kScreen_Width * (idx-1)) / kScreen_Width;
        }else{
            alpha = 1 - ((x_offset - kScreen_Width * idx)) / kScreen_Width;
        }
        titleLabel.alpha = alpha;
    }];
}

- (UIPageControl*)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 25, CGRectGetWidth(self.bounds), 20)];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:77.0 / 255.0 green:186.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f];
    }
    return _pageControl;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
