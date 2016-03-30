//
//  UIMessageInputView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@class UIMessageInputView_zbs;

typedef NS_ENUM(NSInteger, UIMessageInputViewType) {
    UIMessageInputViewTypeRecord,       // 快速记录
    UIMessageInputViewTypeComment,      // 评论
};

typedef NS_ENUM(NSInteger, UIMessageInputViewState) {
    UIMessageInputViewStateSystem,      // 键盘
    UIMessageInputViewStateEmotion,     // 表情
    UIMessageInputViewStateAdd,         // 添加
    UIMessageInputViewStateVoice        // 语音
};

@protocol UIMessageInputViewDelegate;

@interface UIMessageInputView_zbs : UIView

@property (strong, nonatomic) UIPlaceHolderTextView *inputTextView;
@property (copy, nonatomic) NSString *placeHolder;
@property (assign, nonatomic) BOOL isAlwaysShow;
@property (assign, nonatomic, readonly) UIMessageInputViewType type;
@property (weak, nonatomic) id<UIMessageInputViewDelegate>delegate;

+ (instancetype)initMessageInputViewWithType:(UIMessageInputViewType)type;
+ (instancetype)initMessageInputViewWithType:(UIMessageInputViewType)type placeHolder:(NSString*)placeHolder;

- (void)prepareToShowWithView:(UIView*)view;
- (void)prepareToDismiss;
- (BOOL)notAndBecomeFirstResponder;
- (BOOL)isAndResignFirstResponder;
@end

@protocol UIMessageInputViewDelegate <NSObject>

@optional
- (void)messageInputViewRecord;
- (void)messageInputViewAt;
- (void)messageInputView:(UIMessageInputView_zbs*)inputView sendText:(NSString*)text;
- (void)messageInputView:(UIMessageInputView_zbs*)inputView photoType:(NSInteger)photoType;
- (void)messageInputView:(UIMessageInputView_zbs*)inputView sendVoice:(NSString*)file duration:(NSTimeInterval)duration;
- (void)messageInputView:(UIMessageInputView_zbs*)inputView addIndexClicked:(NSInteger)index;

@end