//
//  AFSoundPlaybackHelper.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//


#import "AFSoundPlaybackHelper.h"
#import "LLCAudioCache.h"
#import "FMDB_LLC_AUDIO.h"
#import "CommonFunc.h"

static AFSoundPlayback *playbackHelper = nil;

@implementation AFSoundPlaybackHelper


+ (void)setAFSoundPlaybackHelper:(AFSoundPlayback *)helper{
    playbackHelper = helper;
}

+ (AFSoundPlayback *)getAFSoundPlaybackHelper{
    return playbackHelper;
}

///播放
+(void)play_helper{
    if (playbackHelper) {
        [playbackHelper play];
    }
}

///暂停
+(void)pause_helper{
    if (playbackHelper) {
        [playbackHelper pause];
    }
}

///从指定位置开始播放
+(void)playAtSecond_helper:(NSInteger)second{
    if (playbackHelper) {
        [playbackHelper playAtSecond:second];
        [playbackHelper play];
    }
}

///重新播放
+(void)restart_helper{
    if (playbackHelper) {
        [playbackHelper restart];
        [playbackHelper play];
    }
}

///停止播放
+(void)stop_helper{
    if (playbackHelper) {
        [playbackHelper pause];
        playbackHelper = nil;
    }
}


///播放音频
+(void)playVoiceByUrl:(NSString *)voiceStr{
    /// http://skt.sunke.com//user/resource/file.do?u=LzE3NjY2NS8yMDE2LTAyLTE2Lzg3NTc0MDc4OWY0ODQwN2Y5MmQwODQ2MzdiN2E0NzI1Lm1wMw==
    //    voiceStr = @"http://192.168.5.54:9080/upload/1450763541238.amr";
    NSLog(@"playVoiceByUrl:%@",voiceStr);
    [self stop_helper];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AFSoundItem *item = [[AFSoundItem alloc] initWithStreamingURL:[NSURL URLWithString:voiceStr]];
        [self setAFSoundPlaybackHelper:[[AFSoundPlayback alloc] initWithItem:item]];
        
        [self play_helper];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AFSoundPlaybackHelper getAFSoundPlaybackHelper] listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
                NSLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);

            } andFinishedBlock:^(void){
                NSLog(@"andFinishedBlock");
                
            }];
        });
    });
}

#pragma mark - 缓存 播放

///播放并做缓存
+(void)playAndCacheWithUrl:(NSString *)url{
    if ([[[FMDB_LLC_AUDIO sharedFMDB_LLC_AUDIO_Manager] isExistAudioCache:url] isEqualToString:@"loadingdata"]) {
        NSLog(@"正在缓存中 重新播放");
        [self playVoiceByUrl:url];
        
    }else if ([[[FMDB_LLC_AUDIO sharedFMDB_LLC_AUDIO_Manager] isExistAudioCache:url] isEqualToString:@"cachedata"]) {
        NSLog(@"已缓存 读取本地缓存播放");
        
        ///判断本地文件是否存在
        [self playVoiceByLocalFile:url];
    }else{
        NSLog(@"不存在  播放并做缓存");
        [self audioNotExists:url];
    }
}

///音频文件本地不存在   通过url播放并下载缓存
+(void)audioNotExists:(NSString *)url{
    NSLog(@"不存在  播放并做缓存");
    ///初始化音频model
    LLCAudioCache *audio = [[LLCAudioCache alloc] init];
    audio.audio_url = url;
    audio.audio_name = @"";
    audio.audio_path = @"";
    audio.audio_status = @"loadingdata";
    [[FMDB_LLC_AUDIO sharedFMDB_LLC_AUDIO_Manager] saveAudioData:audio];
    
    ///播放
    [self playVoiceByUrl:url ];
    ///缓存
    [self downloadAndSave:url];
}


///播放本地音频
+(void)playVoiceByLocalFile:(NSString *)voiceStr {
    NSLog(@"playVoiceByLocalFile voiceStr:%@",voiceStr);
    
    LLCAudioCache *audio = [[FMDB_LLC_AUDIO sharedFMDB_LLC_AUDIO_Manager] getAudioData:voiceStr];
    NSLog(@"audio_name:%@",audio.audio_name);
    NSLog(@"audio_path:%@",audio.audio_path);
    ///判断文件是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExisted = [fileManager fileExistsAtPath: audio.audio_path];
    if (isExisted) {
        NSLog(@"本地音频文件存在  直接播放");
        //        NSString *path = [audio.audio_path stringByReplacingOccurrencesOfString:audio.audio_name withString:@""];
        //        NSLog(@"path:%@",path);
        ///播放
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            AFSoundItem *item = [[AFSoundItem alloc] initWithLocalResource:audio.audio_name atPath:audio.audio_path];
            [self setAFSoundPlaybackHelper:[[AFSoundPlayback alloc] initWithItem:item]];
            
            [self play_helper];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AFSoundPlaybackHelper getAFSoundPlaybackHelper] listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
                    NSLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);
                    
                } andFinishedBlock:^(void){
                    NSLog(@"andFinishedBlock");
                    
                }];
            });
        });
        
    }else{
        ///不存在
        NSLog(@"本地文件播放时不存在  url播放并做缓存");
        [self audioNotExists:voiceStr];
    }
}

///下载音频文件并保存到本地
+(void)downloadAndSave:(NSString *)strUrl{
    
    NSURL *url = [NSURL URLWithString:strUrl];
    dispatch_queue_t queue =dispatch_queue_create("loadAudio",NULL);
    dispatch_async(queue, ^{
        NSLog(@"url:%@",url);
        NSData *resultData = [NSData dataWithContentsOfURL:url];
        dispatch_sync(dispatch_get_main_queue(), ^{
            //            NSLog(@"缓存成功---缓存音频信息及文件:%@",resultData);
            NSString *fileDirPath = [CommonFunc getDocumentsPathByDirName:@"AudioDownload"];
            NSString *fileName = [NSString stringWithFormat:@"audio-%@.mp3",[CommonFuntion dateToString:[NSDate date] Format:@"yyyyMMddHHmmss"]];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",fileDirPath,fileName];
            
            ///将音频写入文件
            BOOL isSuccess = [resultData writeToFile:filePath atomically:YES];
            NSLog(@"filePath:%@",filePath);
            if (isSuccess) {
                NSLog(@"写入成功---->");
                LLCAudioCache *audio = [[LLCAudioCache alloc] init];
                audio.audio_url = strUrl;
                //            audio.audio_data = resultData;
                
                audio.audio_name = fileName;
                audio.audio_path = fileDirPath;
                audio.audio_status = @"cachedata";
                [[FMDB_LLC_AUDIO sharedFMDB_LLC_AUDIO_Manager] saveAudioData:audio];
            }else{
                NSLog(@"写入失败----->");
                LLCAudioCache *audio = [[LLCAudioCache alloc] init];
                audio.audio_url = strUrl;
                //            audio.audio_data = resultData;
                audio.audio_name = @"";
                audio.audio_path = @"";
                audio.audio_status = @"";
                [[FMDB_LLC_AUDIO sharedFMDB_LLC_AUDIO_Manager] saveAudioData:audio];
            }
        });
    });
}

@end
