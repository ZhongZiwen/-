//
//  RecordVoice.h
//  DEMOAV
//
//  Created by sungoin-zjp on 15-8-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//


#import <Foundation/Foundation.h>
@class VoiceToolView;

@interface RecordVoice : NSObject


- (RecordVoice *)initWithVoiceToll:(VoiceToolView *)voiceTool;
-(void)beginRecordingByFileName:(NSString *)fileName;
-(void)stopRecording;

///没音量view
- (RecordVoice *)initRecordVoice;
-(void)beginNoVoiceViewRecordingByFileName:(NSString *)fileName;
-(void)stopNoVoiceViewRecording;

@property (nonatomic, copy) void (^StopRecordingBlock)(NSString *filePath,NSString *fileName, NSInteger voiceTime);
@end
