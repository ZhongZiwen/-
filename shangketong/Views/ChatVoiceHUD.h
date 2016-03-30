//
//  ChatVoiceHUD.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ChatVoiceHUDState) {
    ChatVoiceHUDStateRecording,
    ChatVoiceHUDStateCancel
};

@interface ChatVoiceHUD : UIView

+ (void)show;
+ (void)dismiss;
+ (void)changeHUDState:(ChatVoiceHUDState)state;
@end
