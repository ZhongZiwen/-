//
//  EmotionKeyboardView.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 表情类型（目前只有qq表情）
 */
typedef NS_ENUM(NSInteger, EmotionKeyboardViewCategoryImage) {
    EmotionKeyboardViewCategoryImageQQ
};

@protocol EmotionKeyboardViewDelegate;
@protocol EmotionKeyboardViewDataSource;

@interface EmotionKeyboardView : UIView

@property (nonatomic, weak) id<EmotionKeyboardViewDelegate> delegate;
@property (nonatomic, weak) id<EmotionKeyboardViewDataSource> dataSource;

/**
 * 初始化表情键盘
 */
- (instancetype)initWithFrame:(CGRect)frame;


@end

@protocol EmotionKeyboardViewDataSource <NSObject>

/**
 * 通过表情类别，获取对应的表情数据源
 */
- (NSDictionary*)emotionKeyboardView:(EmotionKeyboardView*)emotionKeyboardView emotionSourceAtCategory:(EmotionKeyboardViewCategoryImage)category;


@end

@protocol EmotionKeyboardViewDelegate <NSObject>

/**
 * 表情被点击
 */
- (void)emotionKeyBoardView:(EmotionKeyboardView*)emotionKeyboardView didUseEmotion:(NSString*)emotion;

/**
 * 删除表情
 */
- (void)emotionKeyBoardViewDidPressBackSpace:(EmotionKeyboardView*)emotionKeyboardView;

/**
 * 点击发送按钮
 */
- (void)emotionKeyBoardViewDidPressSendButton:(EmotionKeyboardView *)emotionKeyboardView;
@end
