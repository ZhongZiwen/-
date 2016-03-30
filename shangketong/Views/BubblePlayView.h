//
//  BubblePlayView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AudioPlayView.h"

typedef NS_ENUM(NSInteger, BubbleType) {
    BubbleTypeLeft,
    BubbleTypeRight
};

@interface BubblePlayView : AudioPlayView

@property (nonatomic, assign) BubbleType type;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL showBgImg;
@property (nonatomic, assign) BOOL isUnread;

+ (CGFloat)widthForDuration:(NSTimeInterval)duration;
@end
