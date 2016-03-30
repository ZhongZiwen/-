//
//  EmotionPageView.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmotionPageView : UIView

@property (nonatomic, copy) void(^useEmotionBlock)(NSString*);
@property (nonatomic, copy) void(^deleteEmotionBlock)();

- (instancetype)initWithFrame:(CGRect)frame andEmotionSource:(NSDictionary*)emotionDict andPageIndex:(NSInteger)pageIndex;
@end
