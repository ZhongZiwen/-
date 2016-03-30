//
//  EmotionItem.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmotionItem : UIView

@property (nonatomic, copy) void(^emotionItemBlock) (NSString*);

// 设置表情图片和文字
- (void)configWithImage:(UIImage*)image andName:(NSString*)nameStr;
@end
