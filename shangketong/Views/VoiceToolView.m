//
//  VoiceToolView.m
//  DEMOAV
//
//  Created by sungoin-zjp on 15-8-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//
#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kScreen_Width [UIScreen mainScreen].bounds.size.width
#define Voice_Size 150


#import "VoiceToolView.h"


@interface VoiceToolView ()
///话筒图标
@property (nonatomic, strong) UIImageView *voiceIcon;
///音量图标
@property (nonatomic, strong) UIImageView *voiceSound;
///时长
@property (nonatomic, strong) UILabel *durationTime;
///提示文本
@property (nonatomic, strong) UILabel *capionTitle;

@end

@implementation VoiceToolView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Voice_Size, Voice_Size)];
        backgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:backgroundView];
        
        UIImageView *backImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Voice_Size, Voice_Size)];
        backImg.image = [UIImage imageNamed:@"sound_bg.png"];
        [backgroundView addSubview:backImg];
        
        [backgroundView addSubview:self.voiceIcon];
        [backgroundView addSubview:self.voiceSound];
        [backgroundView addSubview:self.durationTime];
        [backgroundView addSubview:self.capionTitle];
    }
    
    return self;
}


-(void)setVoiceSoundHide:(BOOL)hide{
    _voiceSound.hidden = hide;
}

-(void)setVoiceIconName:(NSString *)voiceIconName{
    _voiceIconName = voiceIconName;
    if ([voiceIconName isEqualToString:@"sound.png"]) {
        _voiceIcon.frame = CGRectMake((Voice_Size-150)/2, 0, 150, 120);
    }else{
        _voiceIcon.frame = CGRectMake((Voice_Size-42)/2, 30, 42, 46);
    }
    _voiceIcon.image = [UIImage imageNamed:voiceIconName];
}

-(void)setVoiceSoundName:(NSString *)voiceSoundName{
    NSLog(@"_voiceIconName:%@",_voiceIconName);
    if ([_voiceIconName isEqualToString:@"sound.png"]) {
        _voiceSound.hidden = NO;
    }else{
        _voiceSound.hidden = YES;
    }
    _voiceSound.image = [UIImage imageNamed:voiceSoundName];
}

-(void)setDurationTimeValue:(NSString *)durationTimeValue{
    _durationTime.text = durationTimeValue;
}

-(void)setCapionTitleValue:(NSString *)capionTitleValue{

    if ([capionTitleValue isEqualToString:@"松开取消发送"]) {
        _capionTitle.textColor = [UIColor redColor];
    }else{
        _capionTitle.textColor = [UIColor whiteColor];
    }
    _capionTitle.text = capionTitleValue;
}


- (UIImageView*)voiceIcon {
    if (!_voiceIcon) {
        _voiceIcon = [[UIImageView alloc] initWithFrame:CGRectMake((Voice_Size-150)/2, 0, 150, 120)];
        _voiceIcon.image = [UIImage imageNamed:@"sound.png"];
//        _voiceIcon.contentMode = UIViewContentModeScaleAspectFill;
//        _voiceIcon.clipsToBounds = YES;
    }
    return _voiceIcon;
}


- (UIImageView*)voiceSound {
    if (!_voiceSound) {
        _voiceSound = [[UIImageView alloc] initWithFrame:CGRectMake((Voice_Size-18)/2, 18, 18, 43)];
//        _voiceSound.contentMode = UIViewContentModeScaleAspectFill;
//        _voiceSound.clipsToBounds = YES;
//        _voiceSound.image = [UIImage imageNamed:@"sound_xin40.png"];
    }
    return _voiceSound;
}


////持续时长
- (UILabel*)durationTime {
    if (!_durationTime) {
        _durationTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, Voice_Size, 20)];
        _durationTime.textAlignment = NSTextAlignmentCenter;
        _durationTime.textColor = [UIColor whiteColor];
        _durationTime.font = [UIFont systemFontOfSize:15.0];
        _durationTime.text = @"0'";
    }
    return _durationTime;
}

///提示信息
- (UILabel*)capionTitle {
    if (!_capionTitle) {
        _capionTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, Voice_Size-30, Voice_Size, 20)];
        _capionTitle.textAlignment = NSTextAlignmentCenter;
        _capionTitle.textColor = [UIColor whiteColor];
        _capionTitle.font = [UIFont systemFontOfSize:15.0];
        _capionTitle.text = @"滑动至此取消发送";
    }
    return _capionTitle;
}

@end
