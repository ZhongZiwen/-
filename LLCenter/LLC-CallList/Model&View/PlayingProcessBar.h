//
//  PlayingProcessBar.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-23.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayingProcessBarDelegate <NSObject>

- (void)processBarDidBeginSlide;
- (void)processBarDidEndSlide:(float)percentage;

@end

@interface PlayingProcessBar : UIView {
    UIView *processBackgroudView,*processCoverView,*onShowView;
    UIButton *btn;
}

@property UIColor *processBarBackgroundColor;//进度条的背景色
@property UIColor *processBarCoverColor;//进度条的播放色
@property UIImageView *cursorImageView;//游标view
@property UIImage *cursorImage;//游标图案,默认可初始化游标view
@property (nonatomic) float process;//播放进度
@property (nonatomic) float processBarHeightOccupy;//进度条高度占的比例,默认0.3
@property (nonatomic,assign) id <PlayingProcessBarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
    processBarBackgroundColor:(UIColor*)tProcessBarBackgroundColor
         processBarCoverColor:(UIColor*)tProcessBarCoverColor
       processBarHeightOccupy:(float)tProcessBarHeightOccupy
              cursorImageView:(UIImageView*)tCursorImageView;

- (void)setPlayingProcess:(float)process;
- (void)setPlayingProcessBarHeightOccupy:(float)processBarHeightOccupy;

@end
