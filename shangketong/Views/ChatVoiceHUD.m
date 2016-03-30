//
//  ChatVoiceHUD.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ChatVoiceHUD.h"

@interface ChatVoiceHUD ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *recordImageView;     // 录音标识
@property (nonatomic, strong) UIImageView *volumeImageView;     // 音量
@property (nonatomic, strong) UILabel *recordLabel;             // 录音状态说明
@end

@implementation ChatVoiceHUD

+ (ChatVoiceHUD*)sharedChatVoiceHud {
    static dispatch_once_t onceToken;
    static ChatVoiceHUD *hud = nil;
    dispatch_once(&onceToken, ^{
        hud = [[ChatVoiceHUD alloc] initWithFrame:kScreen_Bounds];
    });
    return hud;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0];
        [self addSubview:self.backgroundView];
        [self.backgroundView addSubview:self.recordImageView];
        [self.backgroundView addSubview:self.recordLabel];
    }
    return self;
}

#pragma mark - Private Method
- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recordImageView.image = [UIImage imageNamed:@"RecordingBkg"];
        self.recordLabel.text = @"手指上滑，取消发送";
        
        [kKeyWindow addSubview:self];
    });
}

- (void)dismiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.recordImageView.image = [UIImage imageNamed:@"RecordingBkg"];
        self.recordLabel.backgroundColor = [UIColor clearColor];
        self.recordLabel.text = @"手指上滑，取消发送";
        
        [self removeFromSuperview];
    });
}

- (void)changeHudState:(ChatVoiceHUDState)state {
    if (state == ChatVoiceHUDStateRecording) {
        
        self.recordImageView.image = [UIImage imageNamed:@"RecordingBkg"];
        self.recordLabel.backgroundColor = [UIColor clearColor];
        self.recordLabel.text = @"手指上滑，取消发送";
        return;
    }
    
    self.recordImageView.image = [UIImage imageNamed:@"RecordCancel"];
    self.recordLabel.backgroundColor = [UIColor redColor];
    self.recordLabel.text = @"松开手指，取消发送";
}

#pragma mark - Publick Method
+ (void)show {
    [[ChatVoiceHUD sharedChatVoiceHud] show];
}

+ (void)dismiss {
    [[ChatVoiceHUD sharedChatVoiceHud] dismiss];
}

+ (void)changeHUDState:(ChatVoiceHUDState)state {
    [[ChatVoiceHUD sharedChatVoiceHud] changeHudState:state];
}

#pragma mark - getters and setters
- (UIView*)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        _backgroundView.center = CGPointMake(kScreen_Width / 2.0, kScreen_Height / 2.0);
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.8];
        _backgroundView.layer.cornerRadius = 10;
        _backgroundView.layer.masksToBounds = YES;
        _backgroundView.clipsToBounds = YES;
    }
    return _backgroundView;
}

- (UIImageView*)recordImageView {
    if (!_recordImageView) {
        UIImage *image = [UIImage imageNamed:@"RecordingBkg"];
        _recordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        _recordImageView.center = CGPointMake(CGRectGetWidth(_backgroundView.bounds)/2.0, (CGRectGetHeight(_backgroundView.bounds)-30)/2.0);
    }
    return _recordImageView;
}

- (UILabel*)recordLabel {
    if (!_recordLabel) {
        _recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(_backgroundView.bounds)-10-20, CGRectGetWidth(_backgroundView.bounds)-20, 20)];
        _recordLabel.textColor = [UIColor whiteColor];
        _recordLabel.textAlignment = NSTextAlignmentCenter;
        _recordLabel.font = [UIFont systemFontOfSize:14];
    }
    return _recordLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
