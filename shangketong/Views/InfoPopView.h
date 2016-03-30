//
//  InfoPopView.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoPopView : UIView

/** 最大宽度*/
@property (nonatomic, assign) CGFloat maxWidth;

/** 标题*/
@property (nonatomic, copy) NSString *titleString;

/** 详情*/
@property (nonatomic, strong) NSArray *detailArray;

- (void)showInView:(UIView*)view;

@end
