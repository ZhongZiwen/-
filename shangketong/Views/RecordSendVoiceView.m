//
//  RecordSendVoiceView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RecordSendVoiceView.h"
#import "AudioRecordView.h"
#import "CirclePlayView.h"
#import "AudioVolumeView.h"
#import "AudioPlayView.h"

typedef NS_ENUM(NSInteger, RecordSendVoiceViewState) {
    RecordSendVoiceViewStateReady,
    RecordSendVoiceViewStateRecording,
    RecordSendVoiceViewStateFinished,
    RecordSendVoiceViewStateCancel
};

@interface RecordSendVoiceView ()<AudioRecordViewDelegate>

@property (strong, nonatomic) UILabel *recordTipsLabel;
@property (strong, nonatomic) UILabel *bottomLabel;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) AudioRecordView *recordView;
@property (strong, nonatomic) CirclePlayView *circlePlayView;
@property (strong, nonatomic) AudioVolumeView *volumeLeftView;
@property (strong, nonatomic) AudioVolumeView *volumeRightView;

@property (assign, nonatomic) RecordSendVoiceViewState state;
@property (assign, nonatomic) int duration;
@property (assign, nonatomic) int playDuration;
@property (strong, nonatomic) NSTimer *timer;

@property (copy, nonatomic) NSString *file;
@end

@implementation RecordSendVoiceView

- (void)dealloc {
    self.state = RecordSendVoiceViewStateReady;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        
        [self addSubview:self.recordTipsLabel];
        
        _volumeLeftView = [[AudioVolumeView alloc] initWithFrame:CGRectMake(0, 0, kAudioVolumeViewWidth, kAudioVolumeViewHeight)];
        _volumeLeftView.type = AudioVolumeViewTypeLeft;
        _volumeLeftView.hidden = YES;
        [self addSubview:_volumeLeftView];
        
        _volumeRightView = [[AudioVolumeView alloc] initWithFrame:CGRectMake(0, 0, kAudioVolumeViewWidth, kAudioVolumeViewHeight)];
        _volumeRightView.type = AudioVolumeViewTypeRight;
        _volumeRightView.hidden = YES;
        [self addSubview:_volumeRightView];
        
        [self addSubview:self.recordView];
        [self addSubview:self.circlePlayView];
        [self addSubview:self.bottomLabel];
        [self addSubview:self.deleteButton];
        
        _circlePlayView.hidden = YES;
        
        _duration = 0;
        self.state = RecordSendVoiceViewStateReady;
    }
    return self;
}


#pragma mark - private method
- (NSString *)formattedTime:(NSInteger)duration {
    return [NSString stringWithFormat:@"%02d:%02d", duration / 60, duration % 60];
}

- (void)deleteButtonPress {
    [[NSFileManager defaultManager] removeItemAtPath:_file error:nil];
    _duration = 0;
    self.state = RecordSendVoiceViewStateReady;
}

- (void)setState:(RecordSendVoiceViewState)state {
    _state = state;
    
    switch (_state) {
        case RecordSendVoiceViewStateReady: {
            _recordTipsLabel.textColor = [UIColor colorWithRGBHex:0x999999];
            _recordTipsLabel.text = @"按住说话";
            _volumeLeftView.hidden = YES;
            _volumeRightView.hidden = YES;
            
            _bottomLabel.hidden = NO;
            _deleteButton.hidden = YES;
            
            _recordView.hidden = NO;
            _circlePlayView.hidden = YES;
        }
            break;
        case RecordSendVoiceViewStateRecording: {
            if (_duration < ([AudioManager shared].maxRecordDuration - 5)) {
                _recordTipsLabel.textColor = [UIColor colorWithRGBHex:0x2faeea];
            }else {
                _recordTipsLabel.textColor = [UIColor colorWithRGBHex:0xDE4743];
            }
            _recordTipsLabel.text = [self formattedTime:_duration];
        }
            break;
        case RecordSendVoiceViewStateFinished: {
            _recordTipsLabel.textColor = [UIColor colorWithRGBHex:0x2faeea];
            _recordTipsLabel.text = [self formattedTime:_duration];

            _volumeLeftView.hidden = YES;
            _volumeRightView.hidden = YES;
            
            _deleteButton.hidden = NO;
            _bottomLabel.hidden = YES;
            
            _recordView.hidden = YES;
            _circlePlayView.hidden = NO;
        }
            break;
        case RecordSendVoiceViewStateCancel: {
            _recordTipsLabel.textColor = [UIColor colorWithRGBHex:0x999999];
            _recordTipsLabel.text = @"松开取消";
            
            _volumeLeftView.hidden = YES;
            _volumeRightView.hidden = YES;
        }
        default:
            break;
    }
    
    [_recordTipsLabel sizeToFit];
    [_recordTipsLabel setCenterX:CGRectGetWidth(self.bounds) / 2];
    [_recordTipsLabel setCenterY:20];
    
    if (state == RecordSendVoiceViewStateRecording) {
        _volumeLeftView.center = CGPointMake(_recordTipsLabel.frame.origin.x - _volumeLeftView.frame.size.width/2 - 12, _recordTipsLabel.center.y);
        _volumeLeftView.hidden = NO;
        _volumeRightView.center = CGPointMake(_recordTipsLabel.frame.origin.x + _recordTipsLabel.frame.size.width + _volumeRightView.frame.size.width/2 + 12, _recordTipsLabel.center.y);
        _volumeRightView.hidden = NO;
    }
}

#pragma mark - RecordTimer
- (void)startTimer {
    _duration = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(increaseRecordTime) userInfo:nil repeats:YES];
}

- (void)increaseRecordTime {
    _duration++;
    if (self.state == RecordSendVoiceViewStateRecording) {
        //update time label
        self.state = RecordSendVoiceViewStateRecording;
    }
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - AudioRecordViewDelegate
- (void)recordViewRecordStarted:(AudioRecordView *)recordView {
    
    [_volumeLeftView clearVolume];
    [_volumeRightView clearVolume];
    self.state = RecordSendVoiceViewStateRecording;
    [self startTimer];
}

- (void)recordViewRecordFinished:(AudioRecordView *)recordView file:(NSString *)file duration:(NSTimeInterval)duration {
    [self stopTimer];
    if (_state == RecordSendVoiceViewStateRecording) {
        self.state = RecordSendVoiceViewStateFinished;
        _file = file;
        [_circlePlayView setUrl:[NSURL fileURLWithPath:_file]];
        _circlePlayView.duration = duration;
        if (self.recordSuccessfully) {
            self.recordSuccessfully(file, duration);
        }
    }else if (_state == RecordSendVoiceViewStateCancel) {
        self.state = RecordSendVoiceViewStateReady;
        _duration = 0;
        // 删除录音文件
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
        if (self.deleteRecordBlock) {
            self.deleteRecordBlock();
        }
    }
}

- (void)recordView:(AudioRecordView *)recordView touchStateChanged:(AudioRecordViewTouchState)touchState {
    if (_state == RecordSendVoiceViewStateReady)
        return;
    
    if (touchState == AudioRecordViewTouchStateInside) {
        self.state = RecordSendVoiceViewStateRecording;
    }else {
        self.state = RecordSendVoiceViewStateCancel;
    }
}

- (void)recordView:(AudioRecordView *)recordView volume:(double)volume {
    [_volumeLeftView addVolume:volume];
    [_volumeRightView addVolume:volume];
}

- (void)recordView:(AudioRecordView *)recordView error:(NSError *)error {
    [self stopTimer];
    if (_state == RecordSendVoiceViewStateRecording) {
        [NSObject showHudTipStr:error.domain];
    }
    
    self.state = RecordSendVoiceViewStateReady;
    _duration = 0;
}

#pragma mark - setters and getters
- (UILabel*)recordTipsLabel {
    if (!_recordTipsLabel) {
        _recordTipsLabel = [[UILabel alloc] init];
        _recordTipsLabel.font = [UIFont systemFontOfSize:18];
    }
    return _recordTipsLabel;
}

- (AudioRecordView*)recordView {
    if (!_recordView) {
        _recordView = [[AudioRecordView alloc] initWithFrame:CGRectMake(0, 0, 86, 86)];
        [_recordView setY:62];
        [_recordView setCenterX:CGRectGetWidth(self.bounds) / 2.0];
        _recordView.delegate = self;
    }
    return _recordView;
}

- (CirclePlayView*)circlePlayView {
    if (!_circlePlayView) {
        _circlePlayView = [[CirclePlayView alloc] initWithFrame:CGRectMake(0, 0, 86, 86)];
        [_circlePlayView setCenterX:CGRectGetWidth(self.bounds) / 2.0];
        [_circlePlayView setY:62];
        [_circlePlayView doCircleFrame];
    }
    return _circlePlayView;
}

- (UILabel*)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.font = [UIFont systemFontOfSize:12];
        _bottomLabel.textColor = [UIColor colorWithRGBHex:0x999999];
        _bottomLabel.text = @"向上滑动，取消录音";
        [_bottomLabel sizeToFit];
        [_bottomLabel setCenterX:CGRectGetWidth(self.bounds) / 2];
        [_bottomLabel setCenterY:CGRectGetHeight(self.bounds) - 25];
    }
    return _bottomLabel;
}

- (UIButton*)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setWidth:64];
        [_deleteButton setHeight:30];
        [_deleteButton setCenterX:kScreen_Width / 2];
        [_deleteButton setCenterY:CGRectGetMidY(_bottomLabel.frame)];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_deleteButton setTitleColor:[UIColor iOS7darkGrayColor] forState:UIControlStateNormal];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
