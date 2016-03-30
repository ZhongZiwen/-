//
//  PlayRecordVoice.m
//  DEMOAV
//
//  Created by sungoin-zjp on 15-8-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PlayRecordVoice.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayRecordVoice ()<AVAudioPlayerDelegate>{
    
}

///播放器
@property(nonatomic,strong)AVAudioPlayer *player;

@end

@implementation PlayRecordVoice

-(void)pllayByFilePath:(NSString *)filePath{
    NSError *playerError;
    //播放
    _player = nil;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:&playerError];
    _player.delegate = self;
    if (_player == nil)
    {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }else{
        NSLog(@"---play---:%@",filePath);
        [_player play];
    }
    
    [_player stop];
}


-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"audioPlayerDidFinishPlaying:%i",flag);
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"audioPlayerDecodeErrorDidOccur:%@",error);
}


@end
