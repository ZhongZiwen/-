//
//  UIMessageInputView.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

typedef NS_ENUM(NSInteger, UIMessageInputViewType) {
    UIMessageInputViewTypeSimple,       // 只有at功能
    UIMessageInputViewTypeMedia,        // 有录音、表情和添加图片
    UIMessageInputViewTypeWorkReport    // 工作报告中 批阅或评论
};

typedef NS_ENUM(NSInteger, UIMessageInputViewState) {
    UIMessageInputViewStateSystem,
    UIMessageInputViewStateEmotion,
    UIMessageInputViewStateVoice,
    UIMessageInputViewStateAdd
};

@class UIMessageInputView;
@protocol UIMessageInputViewDelegate <NSObject>

@optional
- (void)messageInputView:(UIMessageInputView*)inputView sendText:(NSString*)text;
- (void)messageInputView:(UIMessageInputView*)inputView addIndexClicked:(NSInteger)index;
- (void)messageInputView:(UIMessageInputView*)inputView heightToBottomChanged:(CGFloat)heightToBottom;
- (void)getWithVoiceFileData:(NSData *)data withVoiceFileName:(NSString *)name withVoiceFileTime:(NSInteger)voiceTime;
@end

@interface UIMessageInputView : UIView

@property (nonatomic, strong) UIPlaceHolderTextView *inputTextView;         // 文字输入框

@property (nonatomic, assign) BOOL isAlwaysShow;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic, copy) void(^atBlock)();
@property (nonatomic, weak) id<UIMessageInputViewDelegate>delegate;

// 工作报告
@property (nonatomic, assign) BOOL isApprove;   // 批阅  评论

+ (instancetype)initMessageInputViewWithType:(UIMessageInputViewType)type andRootView:(UIView*)rootView;
+ (instancetype)initMessageInputViewWithType:(UIMessageInputViewType)type andRootView:(UIView*)rootView placeHolder:(NSString*)placeHolder;

- (void)prepareToShow;
- (void)prepareToDismiss;
- (BOOL)notAndBecomeFirstResponder;
- (BOOL)isAndResignFirstResponder;
- (BOOL)isCustomFirstResponder;

-(void)notifyInputView:(NSString *)str;
@end