//
//  AudioRecordView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioRecordView;

typedef NS_ENUM(NSInteger, AudioRecordViewTouchState) {
    AudioRecordViewTouchStateInside,
    AudioRecordViewTouchStateOutside
};

@protocol AudioRecordViewDelegate <NSObject>

@optional

- (void)recordViewRecordStarted:(AudioRecordView*)recordView;
- (void)recordViewRecordFinished:(AudioRecordView*)recordView file:(NSString*)file duration:(NSTimeInterval)duration;

- (void)recordView:(AudioRecordView*)recordView touchStateChanged:(AudioRecordViewTouchState)touchState;
- (void)recordView:(AudioRecordView*)recordView volume:(double)volume;
- (void)recordView:(AudioRecordView*)recordView error:(NSError*)error;
@end

@interface AudioRecordView : UIControl

@property (assign, readonly, nonatomic) BOOL isRecording;
@property (weak, nonatomic) id<AudioRecordViewDelegate>delegate;
@end
