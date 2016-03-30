//
//  EmotionLabel.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmotionMatchParser;

@interface EmotionLabel : UILabel

@property (nonatomic, assign) BOOL attributed;
@property (nonatomic, assign) BOOL linesLimit;
@property (nonatomic, weak) EmotionMatchParser *emotionParser;
@end
