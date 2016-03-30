//
//  PlayingProcessBar.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-23.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "PlayingProcessBar.h"

#define DEFAULT_PROCESS_BAR_OCCUPY 0.3

@implementation PlayingProcessBar
@synthesize delegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.processBarBackgroundColor = GetColorWithRGB(185, 185, 185);
        self.processBarCoverColor = GetColorWithRGB(0, 110, 255);
        self.cursorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 17, 2, self.frame.size.height*0.3)];
        self.cursorImage = [UIImage imageNamed:@"calllist_proccess_bar.png"];
//        self.clipsToBounds = YES;
        
        self.process = 0.f;
        self.processBarHeightOccupy = DEFAULT_PROCESS_BAR_OCCUPY;
        
        [self refreshView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame
    processBarBackgroundColor:(UIColor*)tProcessBarBackgroundColor
         processBarCoverColor:(UIColor*)tProcessBarCoverColor
       processBarHeightOccupy:(float)tProcessBarHeightOccupy
              cursorImageView:(UIImageView*)tCursorImageView {
    self = [super initWithFrame:frame];
    if (self) {
        if (!tProcessBarBackgroundColor) {
            tProcessBarBackgroundColor = GetColorWithRGB(185, 185, 185);
        }
        if (!tProcessBarCoverColor) {
            tProcessBarCoverColor = GetColorWithRGB(0, 110, 255);
        }
        if (!tCursorImageView) {
            tCursorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 17, 2, self.frame.size.height*0.3)];
            self.cursorImage = [UIImage imageNamed:@"calllist_proccess_bar.png"];
        }
        if (!tProcessBarHeightOccupy) {
            tProcessBarHeightOccupy = DEFAULT_PROCESS_BAR_OCCUPY;
        }
        
        self.processBarBackgroundColor = tProcessBarBackgroundColor;
        self.processBarCoverColor = tProcessBarCoverColor;
        self.cursorImageView = tCursorImageView;
        self.process = 0.0f;
        self.processBarHeightOccupy = tProcessBarHeightOccupy;
        
//        self.clipsToBounds = YES;
    }
    
    [self refreshView];
    
    return self;
}

- (void)setPlayingProcess:(float)process {
    if (self.process != process) {
        self.process = process;
        [self refreshView];
    }
}

- (void)setPlayingProcessBarHeightOccupy:(float)processBarHeightOccupy {
    if (self.processBarHeightOccupy != processBarHeightOccupy) {
        self.processBarHeightOccupy = processBarHeightOccupy;
        [self refreshView];
    }
}

- (void)refreshView {
    float widthMargin = 20.0;
    //展示区域
    onShowView = [[UIView alloc] initWithFrame:CGRectMake(widthMargin, 0, self.frame.size.width - 2 * widthMargin, self.frame.size.height)];
    onShowView.backgroundColor = [UIColor clearColor];
    [self addSubview:onShowView];
    
    //进度条背景
    processBackgroudView = [[UIView alloc] initWithFrame:CGRectMake(0, onShowView.frame.size.height*(1 - self.processBarHeightOccupy) / 2.0, onShowView.frame.size.width, onShowView.frame.size.height * self.processBarHeightOccupy)];
    processBackgroudView.backgroundColor = self.processBarBackgroundColor;
    if (![processBackgroudView isDescendantOfView:onShowView]) {
        [onShowView addSubview:processBackgroudView];
    }
    //进度条高亮 
    float coverWidth = processBackgroudView.frame.size.width * self.process;
    if (coverWidth > processBackgroudView.frame.size.width) {
        coverWidth = processBackgroudView.frame.size.width;
    }
    processCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, coverWidth,processBackgroudView.frame.size.height)];
    processCoverView.backgroundColor = self.processBarCoverColor;
    if (![processCoverView isDescendantOfView:processBackgroudView]) {
        [processBackgroudView addSubview:processCoverView];
    }
    //进度条游标
    float cursorX = onShowView.frame.size.width * self.process;
    if (cursorX >= onShowView.frame.size.width) {
        cursorX = onShowView.frame.size.width;
    }
    CGRect cursorRect = self.cursorImageView.frame;
    cursorRect.origin.x = cursorX;
    self.cursorImageView.frame = cursorRect;
    self.cursorImageView.image = self.cursorImage;
    if (![self.cursorImageView isDescendantOfView:onShowView]) {
        [onShowView addSubview:self.cursorImageView];
    }
    [onShowView bringSubviewToFront:self.cursorImageView];
    
    if (!btn) {
        btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        btn.backgroundColor = [UIColor clearColor];
//        btn.alpha = 0.3;
        [btn addTarget:self action:@selector(dragBegan:withEvent:) forControlEvents: UIControlEventTouchDown];
        [btn addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents: UIControlEventTouchDragInside];
        [btn addTarget:self action:@selector(dragEnded:withEvent:) forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self addSubview:btn];
        
    }
    [self bringSubviewToFront:btn];
}

- (void)dragBegan:(UIControl *)c withEvent:ev {
    NSLog(@"Button  moving bagin ......");
    if ([delegate respondsToSelector:@selector(processBarDidBeginSlide)]) {
        [delegate processBarDidBeginSlide];
    }
}

- (void)dragMoving:(UIControl *)c withEvent:ev {
    NSLog(@"Button  is moving ..............");
    float positionX = [[[ev allTouches] anyObject] locationInView:self].x;
    [self setSliderPosition:positionX];
}

- (void)dragEnded:(UIControl *)c withEvent:ev {
    NSLog(@"Button  moving end..............");
    float positionX = [[[ev allTouches] anyObject] locationInView:self].x;
    [self setSliderPosition:positionX];
    
    float percentage = (positionX-20) / onShowView.frame.size.width;
    if (percentage < 0) {
        percentage = 0;
    }
    if (percentage > 1.0) {
        percentage = 1.0;
    }
    if ([delegate respondsToSelector:@selector(processBarDidEndSlide:)]) {
        [delegate processBarDidEndSlide:percentage];
    }
}

- (void)setSliderPosition:(float)positionX {
    NSLog(@"========= current x:%f ========",positionX);
    CGRect cRect = self.cursorImageView.frame;
    
    if (positionX >= 0 && positionX + self.cursorImageView.frame.size.width <= self.frame.size.width) {
        cRect.origin.x = positionX;
    }
    else if (positionX < 0) {
        cRect.origin.x = 0;
        positionX = 0;
    }
    else if (positionX + self.cursorImageView.frame.size.width > self.frame.size.width) {
        cRect.origin.x = self.frame.size.width - self.cursorImageView.frame.size.width;
        positionX = self.frame.size.width - self.cursorImageView.frame.size.width;
    }
//    self.cursorImageView.frame = cRect;
    float percentage = (positionX-20) / onShowView.frame.size.width;
    if (percentage < 0) {
        percentage = 0;
    }
    if (percentage > 1.0) {
        percentage = 1.0;
    }
    [self setPlayingProcess:percentage];
}

@end
