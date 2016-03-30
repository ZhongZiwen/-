//
//  ReleaseToolView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ReleaseToolView.h"
#import "UIView+Common.h"
#import "NSString+Common.h"
#import "DACircularProgressView.h"
#import "RecordVoice.h"
#import "AFSoundManager.h"

//默认最大录音时间
#define kDefaultMaxRecordTime  10
#define kVoiceView_Height 216.0

#define kBGButtonColor [UIColor colorWithRed:(CGFloat)245/255.0 green:(CGFloat)245/255.0 blue:(CGFloat)245/255.0 alpha:1.0f]

@interface ReleaseToolView ()

@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) UIButton *privateBtn;

@property (nonatomic, strong) UIView *voiceView;
@property (nonatomic, strong) UIButton *pressVoiceBtn;
@property (strong, nonatomic) DACircularProgressView *progressView;
@property (nonatomic, strong) UIButton *deleteVoiceBtn;
@property (nonatomic, strong) UILabel *titleVoice;
@property (strong, nonatomic) NSTimer *timer;
///录音还是播放
@property (assign, nonatomic) BOOL isRecordAction;

///播放中 还是暂停
@property (assign, nonatomic) BOOL isPlaying;
///最大或实际长度
@property (nonatomic, assign) float curDurationVoice;


@property (nonatomic, strong) RecordVoice *recordVoice;
@property (nonatomic, strong)  NSString *pathFile;
@property (nonatomic, strong)  NSString *nameFile;
@property (nonatomic, strong) AFSoundPlayback *playback;

@end

@implementation ReleaseToolView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.locationBtn];
        [self addSubview:self.privateBtn];
        
        
        if (frame.size.height == 88) {
            
        }else{
            ///有语音
            [self addSubview:self.voiceView];
        }
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 44, CGRectGetWidth(self.bounds), 44)];
        backgroundView.backgroundColor = kBGButtonColor;
        [backgroundView addLineUp:YES andDown:YES];
        [self addSubview:backgroundView];
        
        // acitvity_img_press@2x
//        NSArray *imageArray = @[@"activity_take_photo", @"acitvity_img", @"acitvity_at", @"acitvity_voice"];

        NSArray *imageArray;
        if (frame.size.height == 88) {
            imageArray = @[@"activity_take_photo", @"acitvity_img", @"acitvity_at"];
        }else{
            imageArray = @[@"activity_take_photo", @"acitvity_img", @"acitvity_at", @"acitvity_voice"];
        }
        
        for (int i = 0; i < imageArray.count; i ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(30 + (30 + 30) * i, 7, 30, 30);
            button.tag = 200 + i;
            [button setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_press", imageArray[i]]] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
            [backgroundView addSubview:button];
        }
    }
    return self;
}


#pragma mark - event response
- (void)locationBtnPress {
    if (self.locationBlock) {
        self.locationBlock();
    }
}

- (void)privateBtnPress {
    if (self.privateBlock) {
        self.privateBlock();
    }
}

- (void)buttonPress:(UIButton*)sender {

    if (self.toolSelectedBlock) {
        self.toolSelectedBlock(sender.tag - 200);
    }
}

#pragma mark - setters and getters
- (void)setLocationBtnTitle:(NSString *)locationBtnTitle {
    if (locationBtnTitle == nil || [locationBtnTitle isEqualToString:@""]) {
        locationBtnTitle = @"插入位置";
    }
    if ([locationBtnTitle isEqualToString:@"插入位置"]) {
        UIImage *image = [UIImage imageNamed:@"acitvity_position"];
        [_locationBtn setImage:image forState:UIControlStateNormal];
        [_locationBtn setTitle:locationBtnTitle forState:UIControlStateNormal];
        
        CGFloat strWidth = [locationBtnTitle getWidthWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13] constrainedToSize:CGSizeMake(MAXFLOAT, 24)];
        [_locationBtn setWidth:strWidth + image.size.width + 30];
    }else{
        UIImage *image = [UIImage imageNamed:@"acitvity_position_press"];
        [_locationBtn setImage:image forState:UIControlStateNormal];
        [_locationBtn setTitle:locationBtnTitle forState:UIControlStateNormal];
        
        CGFloat strWidth = [locationBtnTitle getWidthWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13] constrainedToSize:CGSizeMake(MAXFLOAT, 24)];
        [_locationBtn setWidth:120];
    }
}

- (void)setPrivateBtnTitle:(NSString *)privateBtnTitle {
    
    if ([privateBtnTitle isEqualToString:@""]) {
        _privateBtn.hidden = YES;
        return;
    }else{
        _privateBtn.hidden = NO;
    }
    
    if ([privateBtnTitle isEqualToString:@"公开"]) {
        UIImage *image = [UIImage imageNamed:@"feed_post_public"];
        [_privateBtn setImage:image forState:UIControlStateNormal];
        [_privateBtn setTitle:privateBtnTitle forState:UIControlStateNormal];
        
        CGFloat strWidth = [privateBtnTitle getWidthWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13] constrainedToSize:CGSizeMake(MAXFLOAT, 24)];
        [_privateBtn setX:kScreen_Width - strWidth - image.size.width - 20 - 10];
        [_privateBtn setWidth:strWidth + image.size.width + 20];
    }else {
        UIImage *image = [UIImage imageNamed:@"feed_post_group"];
        [_privateBtn setImage:image forState:UIControlStateNormal];
        [_privateBtn setTitle:privateBtnTitle forState:UIControlStateNormal];
        
        CGFloat strWidth = [privateBtnTitle getWidthWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13] constrainedToSize:CGSizeMake(MAXFLOAT, 24)];
        [_privateBtn setX:kScreen_Width - strWidth - image.size.width - 20 - 10];
        [_privateBtn setWidth:strWidth + image.size.width + 20];
    }
    
}

- (UIButton*)locationBtn {
    if (!_locationBtn) {
        _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _locationBtn.frame = CGRectMake(10, 10, 0, 24);
        _locationBtn.backgroundColor = kBGButtonColor;
        _locationBtn.layer.cornerRadius = CGRectGetHeight(_locationBtn.bounds) / 2.0;
        _locationBtn.clipsToBounds = YES;
        _locationBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _locationBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        [_locationBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_locationBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 4.0, 0.0, 0.0)];
        [_locationBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
        
        
        [_locationBtn addTarget:self action:@selector(locationBtnPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _locationBtn;
}

- (UIButton*)privateBtn {
    if (!_privateBtn) {
        _privateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _privateBtn.frame = CGRectMake(0, 10, 0, 24);
        _privateBtn.backgroundColor = kBGButtonColor;
        _privateBtn.layer.cornerRadius = CGRectGetHeight(_locationBtn.bounds) / 2.0;
        _privateBtn.clipsToBounds = YES;
        _privateBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        [_privateBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_privateBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -4.0, 0.0, 0.0)];
        [_privateBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -4.0)];
        [_privateBtn addTarget:self action:@selector(privateBtnPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _privateBtn;
}


#pragma mark - 语音view
-(UIView *)voiceView{
    if (!_voiceView) {
        _voiceView = [[UIView alloc] initWithFrame:CGRectMake(0, 89, kScreen_Width, kVoiceView_Height)];
        _voiceView.backgroundColor = [UIColor whiteColor];
        
        [_voiceView addSubview:self.titleVoice];
        [_voiceView addSubview:self.progressView];
        [_voiceView addSubview:self.pressVoiceBtn];
        [_voiceView addSubview:self.deleteVoiceBtn];
        self.durationVoice = 0;
    }
    return _voiceView;
}


///时长 3“
-(UILabel *)titleVoice{
    if (!_titleVoice) {
        _titleVoice = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
        _titleVoice.textColor = [UIColor darkGrayColor];
        [_titleVoice setFont:[UIFont systemFontOfSize:15.0]];
        _titleVoice.textAlignment = NSTextAlignmentCenter;
       _titleVoice.text = @"按住录音";
    }
    return _titleVoice;
}

///录音/播放按钮
-(UIButton *)pressVoiceBtn{
    if (!_pressVoiceBtn) {
        _pressVoiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pressVoiceBtn.frame = CGRectMake((kScreen_Width-140)/2, 32, 140, 140);
        [_pressVoiceBtn setBackgroundImage:[UIImage imageNamed:@"activity_record.png"] forState:UIControlStateNormal];
        [_pressVoiceBtn setBackgroundImage:[UIImage imageNamed:@"activity_record_press.png"] forState:UIControlStateHighlighted];
        
        
        
        [_pressVoiceBtn addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
        [_pressVoiceBtn addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return _pressVoiceBtn;
}


///进度条
-(DACircularProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake((kScreen_Width-152)/2, 26, 152, 152)];
        _progressView.roundedCorners = NO;
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.progressTintColor = [UIColor yellowColor];
        _progressView.thicknessRatio = 0.1f;
    }
    return _progressView;
}


///删除按钮
-(UIButton *)deleteVoiceBtn{
    if (!_deleteVoiceBtn) {
        _deleteVoiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteVoiceBtn.frame = CGRectMake((kScreen_Width-40)/2, 190, 40, 25);
        [_deleteVoiceBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteVoiceBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _deleteVoiceBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_deleteVoiceBtn addTarget:self action:@selector(deleteVoiceFile) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteVoiceBtn;
}


#pragma mark - 事件

-(void)deleteVoiceFile{
    self.durationVoice = 0;
    _titleVoice.text = @"按住录音";
    [_pressVoiceBtn setBackgroundImage:[UIImage imageNamed:@"activity_record.png"] forState:UIControlStateNormal];
    [_pressVoiceBtn setBackgroundImage:[UIImage imageNamed:@"activity_record_press.png"] forState:UIControlStateHighlighted];
    _deleteVoiceBtn.hidden = YES;
    
    [_progressView setProgress:0 animated:NO];
    _progressView.progress = 0;
    self.isPlaying = NO;

    if (_playback) {
        [_playback pause];
    }
    ///删除本地录音文件
    [self removeFileFromLocal];
    if (self.RecordingBlock) {
        self.RecordingBlock(@"",@"");
    }
}

-(void)notifyVoiceView{
    if (self.durationVoice == 0) {
        _titleVoice.text = @"按住录音";
        [_pressVoiceBtn setBackgroundImage:[UIImage imageNamed:@"activity_record.png"] forState:UIControlStateNormal];
        [_pressVoiceBtn setBackgroundImage:[UIImage imageNamed:@"activity_record_press.png"] forState:UIControlStateHighlighted];
        _deleteVoiceBtn.hidden = YES;
    }else{
        _titleVoice.text = [NSString stringWithFormat:@"%.f\"",self.durationVoice];
        [_pressVoiceBtn setBackgroundImage:[UIImage imageNamed:@"activity_play.png"] forState:UIControlStateNormal];
         _deleteVoiceBtn.hidden = NO;
    }
    
}

-(void)touchDown{
    NSLog(@"开始");
    if (self.durationVoice == 0) {
        NSLog(@"开始录音");
        self.isPlaying = NO;
        self.isRecordAction = YES;
        ///录音 进度条范围为最大 kDefaultMaxRecordTime
        self.curDurationVoice = kDefaultMaxRecordTime;
        [self startAnimation];
        ///录音
        [self startRecording];
    }else{
        self.isRecordAction = NO;
        ///播放
        NSLog(@"播放");
    }
}

-(void)touchUp{
    
    if (self.isRecordAction) {
        NSLog(@"结束录音");
        [self stopAnimation];
        [_progressView setProgress:0 animated:NO];
        _progressView.progress = 0;
        self.isPlaying = NO;
        [self notifyVoiceView];
        ///结束录音
        [self stopRecord];
    }else{
        ///播放
        ///重新设置进度条范围
        NSLog(@"播放:%f",_progressView.progress);
        if (_progressView.progress == 1) {
            _progressView.progress = 0;
        }
        self.curDurationVoice = self.durationVoice;
        self.isPlaying = !self.isPlaying;
        if (_progressView.progress > 0) {
            if (self.isPlaying) {
                ///播放
                NSLog(@"继续播放");
                [_playback play];
                [self startAnimation];
                [_pressVoiceBtn setBackgroundImage:[UIImage imageNamed:@"activity_pause.png"] forState:UIControlStateNormal];
            }else{
                ///暂停
                NSLog(@"暂停");
                [_playback pause];
                [self stopAnimation];
                [_pressVoiceBtn setBackgroundImage:[UIImage imageNamed:@"activity_play.png"] forState:UIControlStateNormal];
            }
        }else{
            NSLog(@"开始播放");
            [self playVoice];
            self.isPlaying = YES;
            [self startAnimation];
            [_pressVoiceBtn setBackgroundImage:[UIImage imageNamed:@"activity_pause.png"] forState:UIControlStateNormal];
        }

    }
}


- (void)startAnimation
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                  target:self
                                                selector:@selector(progressChange)
                                                userInfo:nil
                                                repeats:YES];
}

- (void)stopAnimation
{
    [self.timer invalidate];
    self.timer = nil;
}


- (void)progressChange
{
    ///录音
    if (self.isRecordAction){
        _titleVoice.text = @"松开结束";
    }
    NSLog(@"progressChange:%f",_progressView.progress);
    NSLog(@"progress:%f",(10000/self.curDurationVoice)*0.0001);
    CGFloat progress = _progressView.progress + (10000/self.curDurationVoice)*0.0001*0.1;
    [_progressView setProgress:progress animated:YES];
    
    if (_progressView.progress >= 1.0f && [self.timer isValid]) {
        
        
        [self stopAnimation];
        [_progressView setProgress:0 animated:NO];
        _progressView.progress = 0;
        self.isPlaying = NO;
        NSLog(@"结束progressChange:%f",_progressView.progress);

        _titleVoice.text = [NSString stringWithFormat:@"%.f\"",self.durationVoice];
        [_pressVoiceBtn setBackgroundImage:[UIImage imageNamed:@"activity_play.png"] forState:UIControlStateNormal];
        _deleteVoiceBtn.hidden = NO;
        
        if (self.isRecordAction) {
            ///结束录音
            [self stopRecord];
        }
    }
    
    if (_progressView.progress > 0.0) {
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.progressTintColor = [UIColor yellowColor];
    } else {
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.progressTintColor = [UIColor clearColor];
    }
    
    ///录音
    if (self.isRecordAction){
//        self.durationVoice++;
        self.durationVoice += (10000/self.curDurationVoice)*0.0001;
    }
}



#pragma mark - 录音相关

- (RecordVoice*)recordVoice {
    if (!_recordVoice) {
        _recordVoice = [[RecordVoice alloc] initRecordVoice];
    }
    return _recordVoice;
}


-(void)startRecording{

    [self.recordVoice beginRecordingByFileName:@"crmrecordvoice"];
    __weak typeof(self) weak_self = self;
    _recordVoice.StopRecordingBlock = ^(NSString *path,NSString *name, NSInteger voiceTime){
        NSLog(@"录音文件路径:%@",path);
        NSLog(@"录音文件名:%@",name);
        
        weak_self.pathFile = path;
        weak_self.nameFile = name;
        weak_self.recordVoice = nil;
        if (weak_self.RecordingBlock) {
            weak_self.RecordingBlock(path,name);
        }
    };
}


-(void)stopRecord{
    if (_recordVoice) {
        [_recordVoice stopRecording];
    }
}



#pragma mark - 播放
-(void)playVoice{
    if (_playback) {
        [_playback pause];
        _playback = nil;
    }
    
    AFSoundItem *item = [[AFSoundItem alloc] initWithLocalResource:_nameFile atPath:_pathFile];
    _playback = [[AFSoundPlayback alloc] initWithItem:item];
    [_playback play];
    
    
    [_playback listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
        
        NSLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);
    } andFinishedBlock:^(void){
        NSLog(@"andFinishedBlock");
        
    }];
}


-(NSData *)getFileByPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        NSLog(@"文件存在--->");
        NSData *data = [fileManager contentsAtPath:path];
        //        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
        NSLog(@"size:%lu",[data length]);
        NSLog(@"size:%lu",[data length]/1024);
        return data;
    }else{
        NSLog(@"文件不存在--->");
        return nil;
    }
}

-(void)removeFileFromLocal{
    NSString *path = [NSString stringWithFormat:@"%@/%@",_pathFile,_nameFile];
    NSLog(@"path:%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    [fileManager removeItemAtPath:path error:&err];
    NSLog(@"removeFileFromLocal--->");
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
