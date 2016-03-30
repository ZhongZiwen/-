//
//  RecordVoice.m
//  DEMOAV
//
//  Created by sungoin-zjp on 15-8-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//


//默认最大录音时间
#define kDefaultMaxRecordTime  60



#import "RecordVoice.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceToolView.h"
#import "CommonFunc.h"

@interface RecordVoice ()<AVAudioRecorderDelegate>{
    NSInteger  timeCount;
     NSString *recordFileDirPath;
    NSString *recordFileName;
}

//录音器
@property(nonatomic,strong)AVAudioRecorder *recorder;
//定时器
@property(nonatomic,strong) NSTimer *timer;
//图片组
@property(nonatomic,strong) NSMutableArray *volumImages;
@property(nonatomic,assign) double lowPassResults;
///录音设置
@property(nonatomic,strong)NSDictionary *recorderSettingsDict;
///录音路径
@property(nonatomic,strong) NSString *recordFilePath;
//@property(nonatomic,strong) NSString *recordFileDirPath;
//@property(nonatomic,strong) NSString *recordFileName;
@property(nonatomic,strong) VoiceToolView *voiceToolView;
@end


@implementation RecordVoice

- (RecordVoice *)initWithVoiceToll:(VoiceToolView *)voiceTool
{
    self = [super init];
    if (self) {
        _voiceToolView = voiceTool;
    }
    return self;
}

- (RecordVoice *)initRecordVoice
{
    self = [super init];
    if (self) {
    }
    return self;
}


-(void)beginRecordingByFileName:(NSString *)fileName{
    
    [self initVoiceSoundImg];
    [self initRecordSetting];
    
    
    recordFileDirPath = [CommonFunc getDocumentsPathByDirName:@"AudioDownload"];
    recordFileName = [NSString stringWithFormat:@"audio-%@.aac",[CommonFuntion dateToString:[NSDate date] Format:@"yyyyMMddHHmmss"]];
   _recordFilePath = [NSString stringWithFormat:@"%@/%@",recordFileDirPath,recordFileName];
    
//    recordFileDirPath = [self documentsPath];
//    recordFileName = [fileName stringByAppendingPathExtension:@"aac"];
//    _recordFilePath = [NSString stringWithFormat:@"%@/%@",recordFileDirPath,recordFileName];
    
    
//    _recordFilePath = [self getPathByFileName:fileName ofType:@"aac"];
    ///有文件存在 删除掉？
    NSLog(@"_recordFilePath:%@",_recordFilePath);
    
    //初始化录音
    _recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:_recordFilePath]
                                                settings:_recorderSettingsDict
                                                   error:nil];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    
    [_recorder prepareToRecord];
    
    timeCount = 0;
     _voiceToolView.durationTimeValue = [NSString stringWithFormat:@"%ti'",timeCount];
    //启动计时器
    [self startTimer];
    
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [_recorder record];
}


///没音量view
-(void)beginNoVoiceViewRecordingByFileName:(NSString *)fileName{
    [self initRecordSetting];
    recordFileDirPath = [self documentsPath];
    recordFileName = [fileName stringByAppendingPathExtension:@"aac"];
    _recordFilePath = [NSString stringWithFormat:@"%@/%@",recordFileDirPath,recordFileName];
    //    _recordFilePath = [self getPathByFileName:fileName ofType:@"aac"];
    ///有文件存在 删除掉？
    NSLog(@"_recordFilePath:%@",_recordFilePath);
    
    //初始化录音
    _recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:_recordFilePath]
                                           settings:_recorderSettingsDict
                                              error:nil];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    
    [_recorder prepareToRecord];
    

    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [_recorder record];
}



-(void)stopRecording{
    //结束定时器
    [self stopTimer];
    
    //录音停止
    if (_voiceToolView) {
        [_voiceToolView removeFromSuperview];
        _voiceToolView = nil;
    }
    if (_recorder) {
        [_recorder stop];
        _recorder = nil;
    }
}

///没音量view
-(void)stopNoVoiceViewRecording{
    if (_recorder) {
        [_recorder stop];
        _recorder = nil;
    }
}

///初始化图片
-(void)initVoiceSoundImg{
    _volumImages = [[NSMutableArray alloc]initWithObjects:@"sound_xin40.png",@"sound_xin60.png",@"sound_xin80.png",
                   @"sound_xin.png",nil];
}

///初始化录音设置
-(void)initRecordSetting{
    
    /*
     AVSampleRateKey, //采样率
     AVFormatIDKey,//音频编码格式
     AVLinearPCMBitDepthKey,//采样位数 默认 16
     AVNumberOfChannelsKey,//通道的数目
     AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式 [NSNumber numberWithBool:NO]
     AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数 [NSNumber numberWithBool:NO]
     AVEncoderAudioQualityKey,//音频编码质量
     */
    
    _recorderSettingsDict = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [_recorderSettingsDict setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [_recorderSettingsDict setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [_recorderSettingsDict setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [_recorderSettingsDict setValue:[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [_recorderSettingsDict setValue:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
}


#pragma mark - 启动定时器
- (void)startTimer{
    NSLog(@"startTimer");
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

#pragma mark - 停止定时器
- (void)stopTimer{
    if (_timer && _timer.isValid){
        [_timer invalidate];
        _timer = nil;
    }
}


#pragma mark - 更新音频峰值
- (void)updateMeters{
    NSLog(@"updateMeters");
    if (_recorder.isRecording){
        //倒计时
        if (timeCount >= kDefaultMaxRecordTime ) {
            NSLog(@"到最大时间了");
            [self stopRecording];
            return;
        }
        
        //更新峰值
        [_recorder updateMeters];
        CGFloat _avgPower = [_recorder peakPowerForChannel:0];
        NSLog(@"_avgPower:%f",_avgPower);
        if (_avgPower >= -50 && _avgPower < -40){
            _voiceToolView.voiceSoundName = [_volumImages objectAtIndex:0];
        }else if (_avgPower >= -40 && _avgPower < -30){
            _voiceToolView.voiceSoundName = [_volumImages objectAtIndex:1];
        }else if (_avgPower >= -30 && _avgPower < -20){
            _voiceToolView.voiceSoundName = [_volumImages objectAtIndex:2];
        }else if (_avgPower >= -20){
            _voiceToolView.voiceSoundName = [_volumImages objectAtIndex:3];
        }else{
            _voiceToolView.voiceSoundName = @"";
        }
            
        /*
        const double ALPHA = 0.05;
        double peakPowerForChannel = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
        _lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * _lowPassResults;
        
        NSLog(@"Average input: %f Peak input: %f Low pass results: %f", [_recorder averagePowerForChannel:0], [_recorder peakPowerForChannel:0], _lowPassResults);
        
        if(_lowPassResults>=0.7){
            _voiceToolView.voiceSoundImage = [_volumImages objectAtIndex:3];
        }else if(_lowPassResults>=0.5){
             _voiceToolView.voiceSoundImage = [_volumImages objectAtIndex:2];
        }else if(_lowPassResults>=0.3){
             _voiceToolView.voiceSoundImage = [_volumImages objectAtIndex:1];
        }else if(_lowPassResults>=0.1){
             _voiceToolView.voiceSoundImage = [_volumImages objectAtIndex:0];
        }else{
            _voiceToolView.voiceSoundImage = @"";
        }
        */
        timeCount += 1;
        _voiceToolView.durationTimeValue = [NSString stringWithFormat:@"%ti'",timeCount];
    }
}


#pragma mark - AVAudioRecorder Delegate Methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"录音停止");
    if (self.StopRecordingBlock) {
        self.StopRecordingBlock(recordFileDirPath,recordFileName, timeCount);
    }
}

///生成目录路径
-(NSString *)documentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

-(NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[[self documentsPath]stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    return fileDirectory;
}

/*
///生成路径
-(NSString *)documentsPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fileDirectory = [[documentsDirectory stringByAppendingPathComponent:fileName]stringByAppendingPathExtension:@"aac"];
    
    return fileDirectory;
}
*/


@end
