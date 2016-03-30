//
//  VoiceToolView.h
//  DEMOAV
//
//  Created by sungoin-zjp on 15-8-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoiceToolView : UIView


@property (nonatomic, copy) NSString *voiceIconName;
@property (nonatomic, copy) NSString *voiceSoundName;
@property (nonatomic, copy) NSString *durationTimeValue;
@property (nonatomic, copy) NSString *capionTitleValue;
-(void)setVoiceSoundHide:(BOOL)hide;

@end
