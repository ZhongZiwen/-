//
//  AFSoundPlaybackHelper.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-12-11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFSoundPlayback.h"


@interface AFSoundPlaybackHelper : AFSoundPlayback

+ (void)setAFSoundPlaybackHelper:(AFSoundPlayback *)helper;
+ (AFSoundPlayback *)getAFSoundPlaybackHelper;


///播放
+(void)play_helper;
///暂停
+(void)pause_helper;
///从指定位置开始播放
+(void)playAtSecond_helper:(NSInteger)second;
///重新播放
+(void)restart_helper;
///停止播放
+(void)stop_helper;


///播放音频
+(void)playVoiceByUrl:(NSString *)voiceStr;

///播放并做缓存
+(void)playAndCacheWithUrl:(NSString *)url;
///下载音频文件并保存到本地
+(void)downloadAndSave:(NSString *)strUrl;

@end
