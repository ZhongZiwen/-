//
//  PhotoBrowser.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PhotoBrowser.h"
#import "PhotoViewState.h"
#import "PhotoZoomingImageView.h"
#import "PhotoItem.h"

@interface PhotoBrowser ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *imgViews;
@end

@implementation PhotoBrowser

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PhotoBrowser *photoBrowser = nil;
    dispatch_once(&onceToken, ^{
        photoBrowser = [[PhotoBrowser alloc] init];
    });
    return photoBrowser;
}

- (id)init {
    self = [self initWithFrame:kScreen_Bounds];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    self.backgroundScale = 0.95;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
    
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)setPhotoItemWithArray:(NSArray *)itemsArray {
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (PhotoItem *tempItem in itemsArray) {
        PhotoViewState *state = [PhotoViewState viewStateForView:tempItem.srcImageView];
        [state setStateWithView:tempItem.srcImageView];
        tempItem.srcImageView.userInteractionEnabled = NO;
        [tempArray addObject:tempItem];
    }
    _imgViews = tempArray;
}

- (void)showWithItems:(NSArray *)items selectedItem:(PhotoItem *)selectedItem {
    if (!items.count) {
        return;
    }
    
    // 两张图片同时点击时
    if (_imgViews.count) {
        return;
    }
    
    [self setPhotoItemWithArray:items];
    
    if (![selectedItem.srcImageView isKindOfClass:[UIImageView class]] || ![_imgViews containsObject:selectedItem]) {
        selectedItem = _imgViews[0];
    }
    
    [self showWithSelectedItem:selectedItem];
}

#pragma mark- Properties
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[backgroundColor colorWithAlphaComponent:0]];
}

- (NSInteger)pageIndex {
    return (_scrollView.contentOffset.x / _scrollView.frame.size.width + 0.5);
}

#pragma mark- View management

- (PhotoItem *)currentItem {
    return [_imgViews objectAtIndex:self.pageIndex];
}

- (void)showWithSelectedItem:(PhotoItem *)selectedItem {
    for(UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    const NSInteger currentPage = [_imgViews indexOfObject:selectedItem];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:self];
    
    self.pageControl.numberOfPages = _imgViews.count;
    self.pageControl.currentPage = currentPage;
    
    const CGFloat fullW = window.frame.size.width;
    const CGFloat fullH = window.frame.size.height;
    
    selectedItem.srcImageView.frame = [window convertRect:selectedItem.srcImageView.frame fromView:selectedItem.srcImageView.superview];
    [window addSubview:selectedItem.srcImageView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _scrollView.alpha = 1;
                         _pageControl.alpha = 1;
                         
                         window.rootViewController.view.transform = CGAffineTransformMakeScale(self.backgroundScale, self.backgroundScale);
                         
                         selectedItem.srcImageView.transform = CGAffineTransformIdentity;
                         
                         CGSize size = (selectedItem.srcImageView.image) ? selectedItem.srcImageView.image.size : selectedItem.srcImageView.frame.size;
                         CGFloat ratio = MIN(fullW / size.width, fullH / size.height);
                         CGFloat W = ratio * size.width;
                         CGFloat H = ratio * size.height;
                         selectedItem.srcImageView.frame = CGRectMake((fullW-W)/2, (fullH-H)/2, W, H);
                     }
                     completion:^(BOOL finished) {
                         _scrollView.contentSize = CGSizeMake(_imgViews.count * fullW, 0);
                         _scrollView.contentOffset = CGPointMake(currentPage * fullW, 0);
                         
                         UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScrollView:)];
                         [_scrollView addGestureRecognizer:gesture];
                         
                         for (int i = 0; i < _imgViews.count; i ++) {
                             PhotoItem *tempItem = _imgViews[i];
                             tempItem.srcImageView.transform = CGAffineTransformIdentity;
                             
                             CGSize size = (tempItem.srcImageView.image) ? tempItem.srcImageView.image.size : tempItem.srcImageView.frame.size;
                             CGFloat ratio = MIN(fullW / size.width, fullH / size.height);
                             CGFloat W = ratio * size.width;
                             CGFloat H = ratio * size.height;
                             tempItem.srcImageView.frame = CGRectMake((fullW-W)/2, (fullH-H)/2, W, H);
                             
                             PhotoZoomingImageView *tmp = [[PhotoZoomingImageView alloc] initWithFrame:CGRectMake(i * fullW, 0, fullW, fullH)];
                             tmp.tag = i + 2000;
                             tmp.imageView = tempItem.srcImageView;
                             if (i == currentPage) {
                                 tmp.url = tempItem.url;
                             }
                             [_scrollView addSubview:tmp];
                         }
                     }
     ];
}


- (void)prepareToDismiss {
    PhotoItem *currentItem = [self currentItem];
    
//    if([self.delegate respondsToSelector:@selector(imageViewer:willDismissWithSelectedView:)]) {
//        [self.delegate imageViewer:self willDismissWithSelectedView:currentView];
//    }
    
    for (PhotoItem *tempItem in _imgViews) {
        if (tempItem != currentItem) {
            PhotoViewState *state = [PhotoViewState viewStateForView:tempItem.srcImageView];
            tempItem.srcImageView.transform = CGAffineTransformIdentity;
            tempItem.srcImageView.transform = state.transform;
            tempItem.srcImageView.image = state.minImage;
            tempItem.srcImageView.frame = state.frame;
            [state.superview addSubview:tempItem.srcImageView];
        }
    }
}

- (void)dismissWithAnimate {
    PhotoItem *currentItem = [self currentItem];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    CGRect rct = currentItem.srcImageView.frame;
    currentItem.srcImageView.transform = CGAffineTransformIdentity;
    currentItem.srcImageView.frame = [window convertRect:rct fromView:currentItem.srcImageView.superview];
    [window addSubview:currentItem.srcImageView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _scrollView.alpha = 0;
                         _pageControl.alpha = 0;
                         
                         window.rootViewController.view.transform =  CGAffineTransformIdentity;
                         
                         PhotoViewState *state = [PhotoViewState viewStateForView:currentItem.srcImageView];
                         currentItem.srcImageView.frame = [window convertRect:state.frame fromView:state.superview];
                         currentItem.srcImageView.transform = state.transform;
                     }
                     completion:^(BOOL finished) {
                         PhotoViewState *state = [PhotoViewState viewStateForView:currentItem.srcImageView];
                         currentItem.srcImageView.transform = CGAffineTransformIdentity;
                         currentItem.srcImageView.transform = state.transform;
                         currentItem.srcImageView.image = state.minImage;
                         currentItem.srcImageView.frame = state.frame;
                         [state.superview addSubview:currentItem.srcImageView];
                         
                         for (PhotoItem *tempItem in _imgViews) {
                             PhotoViewState *_state = [PhotoViewState viewStateForView:currentItem.srcImageView];
                             tempItem.srcImageView.userInteractionEnabled = _state.userInteratctionEnabled;
                         }
                         
                         _imgViews = nil;
                         [self removeFromSuperview];
                     }
     ];
}

#pragma mark- Gesture events

- (void)tappedScrollView:(UITapGestureRecognizer*)sender
{
    [self prepareToDismiss];
    [self dismissWithAnimate];
}

- (void)didPan:(UIPanGestureRecognizer*)sender {
    static PhotoItem *currentItem = nil;
    
    if(sender.state == UIGestureRecognizerStateBegan){
        currentItem = [self currentItem];
        
        UIView *targetView = currentItem.srcImageView.superview;
        while(![targetView isKindOfClass:[PhotoZoomingImageView class]]){
            targetView = targetView.superview;
        }
        
        if(((PhotoZoomingImageView *)targetView).isViewing){
            currentItem = nil;
        }
        else{
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            currentItem.srcImageView.frame = [window convertRect:currentItem.srcImageView.frame fromView:currentItem.srcImageView.superview];
            [window addSubview:currentItem.srcImageView];
            
            [self prepareToDismiss];
        }
    }
    
    if(currentItem){
        if(sender.state == UIGestureRecognizerStateEnded){
            if(_scrollView.alpha>0.5){
                [self showWithSelectedItem:currentItem];
            }
            else{
                [self dismissWithAnimate];
            }
            currentItem = nil;
        }
        else{
            CGPoint p = [sender translationInView:self];
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, p.y);
            transform = CGAffineTransformScale(transform, 1 - fabs(p.y)/1000, 1 - fabs(p.y)/1000);
            currentItem.srcImageView.transform = transform;
            
            CGFloat r = 1-fabs(p.y)/200;
            _scrollView.alpha = MAX(0, MIN(1, r));
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = self.pageIndex;
    
    _pageControl.currentPage = index;
    
    PhotoZoomingImageView *imageView = [_scrollView viewWithTag:index + 2000];
    PhotoItem *item;
    
    if (index < _imgViews.count) {
        item = _imgViews[index];
    }
    
    if (imageView) {
        imageView.url = item.url;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

#pragma mark - setters and getters
- (UIScrollView *)scrollView {
    if(!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator   = NO;
        _scrollView.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1];
        _scrollView.alpha = 0;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        [_pageControl sizeToFit];
        [_pageControl setCenterX:kScreen_Width / 2.0];
        [_pageControl setY:CGRectGetHeight(self.bounds) - 20];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.7 alpha:0.2];
        _pageControl.alpha = 0;
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
