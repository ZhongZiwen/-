//
//  AudioVolumeView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAudioVolumeViewVolumeWidth 2.0f
#define kAudioVolumeViewVolumeMinHeight 3.0f
#define kAudioVolumeViewVolumeMaxHeight 16.0f
#define kAudioVolumeViewVolumePadding 2.0f
#define kAudioVolumeViewVolumeNumber 10

#define kAudioVolumeViewWidth (kAudioVolumeViewVolumeWidth*kAudioVolumeViewVolumeNumber+kAudioVolumeViewVolumePadding*(kAudioVolumeViewVolumeNumber-1))
#define kAudioVolumeViewHeight kAudioVolumeViewVolumeMaxHeight

typedef NS_ENUM(NSInteger, AudioVolumeViewType) {
    AudioVolumeViewTypeLeft,
    AudioVolumeViewTypeRight
};

@interface AudioVolumeView : UIView

@property (nonatomic, assign) AudioVolumeViewType type;

- (void)addVolume:(double)volume;
- (void)clearVolume;
@end
