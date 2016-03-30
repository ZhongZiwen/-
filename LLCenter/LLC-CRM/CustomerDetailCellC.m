//
//  CustomerDetailCellC.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "CustomerDetailCellC.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"
#import "UserSession.h"
#import "AFSoundPlaybackHelper.h"
#import "Reachability.h"
#import "FMDB_LLC_AUDIO.h"
#import "LLCAudioCache.h"

@interface CustomerDetailCellC() <UIAlertViewDelegate,PlayingProcessBarDelegate> {
    NSString *voiceUrlString;
    bool canPlay,isPlaying,isWifi;
    int soundDuration,watchDogCounter;
    float moveToPlayingPercentage,currentPlayingPercentage;
    
    ///当前播放进度
    NSInteger curPlayAtSecond;
    ///当前音频总时长
    NSInteger curTotalDuration;
}
@end


@implementation CustomerDetailCellC

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


///填充cell详情
-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    
    NSInteger vX = DEVICE_BOUNDS_WIDTH-320;
    
    //    labelCurrentTime
    //    labelTotleTime
    //    btnPlay
    //    playingProcessBar
    
    ///播放进度条
    [self setPlayingProcessDetails:item indexPath:indexPath];
    
    ///CurrentTime
    self.labelCurrentTime.text = @"00:00:00";
    self.labelCurrentTime.frame = CGRectMake(185+vX, 15, 60, 20);
    
    ///TotleTime
    int  totleTime = 0;
    if ([item objectForKey:@"DETAIL"] ) {
        totleTime = [[item safeObjectForKey:@"DETAIL"] intValue];
    }
    if (totleTime != 0) {
        self.labelTotleTime.text = [NSString stringWithFormat:@"/%@",[CommonFunc getMinutString:totleTime intervalType:1 mode:1]];
    }else{
        self.labelTotleTime.text = @"/00:00:00";
    }
    self.labelTotleTime.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-75, 15, 70, 20);
    
    voiceUrlString = nil;
    if ([item objectForKey:@"REMARK"] ) {
        voiceUrlString = [item safeObjectForKey:@"REMARK"];
    }
}


///播放条
-(void)setPlayingProcessDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    // 3.判断网络状态
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable) { // 有wifi
        NSLog(@"有wifi");
        isWifi = TRUE;
    }else{
        isWifi = FALSE;
    }
    //    isWifi = NO;//For test
    if (!isWifi && ![[UserSession shareSession] canPlayVoiceWithoutWiFi]) {
        canPlay = NO;
    }
    else {
        canPlay = YES;
    }
    
    [self.playingProcessBar removeFromSuperview];
    self.playingProcessBar = [[PlayingProcessBar alloc] initWithFrame:CGRectMake(40, 0, 150+DEVICE_BOUNDS_WIDTH-320, 50) processBarBackgroundColor:nil processBarCoverColor:nil processBarHeightOccupy:0.13 cursorImageView:nil];
    [self.contentView  addSubview:self.playingProcessBar];
    [self.playingProcessBar setProcess:0.0f];
    [self.playingProcessBar setUserInteractionEnabled:YES];
    self.playingProcessBar.delegate = self;
    
    [self.playingProcessBar setPlayingProcess:0];
    
    NSDictionary *playInfo = [item objectForKey:@"PlayInfo"];
    if (playInfo) {
        NSLog(@"%@",playInfo);
        float pPercetage = [[playInfo objectForKey:@"percentage"] floatValue];
        [self.playingProcessBar setPlayingProcess:pPercetage];
        isPlaying = [[playInfo objectForKey:@"playing"] boolValue];
    }
}



- (void)prepareToPlayVoice {
    //    if (cellType == CallListCellAnswered) {
    //        voiceUrlString = @"http://180.166.192.27:9080/headserver/temp/02153892286_190622.wav";
    //    }
    //    else {
    //        voiceUrlString = @"http://180.166.192.27:9080/headserver/temp/2014061317392202153892286.wav";
    //    }
    //
    //    [self playAndCacheWithUrl:voiceUrlString];
    //    return;
    
    if (voiceUrlString && voiceUrlString.length > 0) {
        [self playAndCacheWithUrl:voiceUrlString];
    }
    else {
        
        [self getVoice];
    }
}



-(void)getVoice{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_VOICE_URL_ACTION] params:params success:^(id jsonResponse) {
        
        NSLog(@"-----jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            //获取录音成功
            voiceUrlString = [jsonResponse objectForKey:@"desc"];
            if ([voiceUrlString respondsToSelector:@selector(length)] && voiceUrlString.length > 0) {
                [self playAndCacheWithUrl:voiceUrlString];
            }
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getVoice];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取录音失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"获取录音失败";
            }
            [CommonFuntion showToast:desc inView:self.contentView];
            self.labelCurrentTime.text = @"00:00:00";
            self.btnPlay.selected = NO;
        }
        
        
    } failure:^(NSError *error) {
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.contentView];
        self.labelCurrentTime.text = @"00:00:00";
        self.btnPlay.selected = NO;
    }];
}





- (IBAction)btnAction:(id)sender {
    
    self.btnPlay.selected = !self.btnPlay.selected;
    if (self.btnPlay.selected) {
        //进入播放状态
        if (!isPlaying) {
            if (isWifi) {
                //                [SVProgressHUD showSuccessWithStatus:@"您当前环境为wifi环境,可试听录音!" durationTime:1.5];
            }
            else {
                if (!canPlay) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您已开启\"仅wifi下试听录音\"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    return;
                }
                else {
                    [CommonFuntion showToast:@"您当前处于2/3/4G网络,试听将会产生流量费用!" inView:self.contentView];
                }
            }
            
            //刚开始播放
            isPlaying = YES;
            self.labelCurrentTime.text = @"正在缓冲";
            if (voiceUrlString && voiceUrlString.length > 0) {
                [self playAndCacheWithUrl:voiceUrlString];
            }
            else {
                 [CommonFuntion showToast:@"播放出错!" inView:self];
                self.labelCurrentTime.text = @"00:00:00";
                return;
                //                [self prepareToPlayVoice];
            }
        }
        else {
            //播放到一半
            [AFSoundPlaybackHelper playAtSecond_helper:curPlayAtSecond];
        }
        
    }
    else {
        //播放到一半
        [AFSoundPlaybackHelper playAtSecond_helper:curPlayAtSecond];
    }
}


#pragma mark - 音频缓存
///播放并做缓存
-(void)playAndCacheWithUrl:(NSString *)url{
    if ([[[FMDB_LLC_AUDIO sharedFMDB_LLC_AUDIO_Manager] isExistAudioCache:url] isEqualToString:@"loadingdata"]) {
        NSLog(@"正在缓存中 重新播放");
        [self playSoundWithUrlString:url isLocalFile:NO andFileName:@""];
        
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
-(void)audioNotExists:(NSString *)url{
    NSLog(@"不存在  播放并做缓存");
    ///初始化音频model
    LLCAudioCache *audio = [[LLCAudioCache alloc] init];
    audio.audio_url = url;
    audio.audio_name = @"";
    audio.audio_path = @"";
    audio.audio_status = @"loadingdata";
    [[FMDB_LLC_AUDIO sharedFMDB_LLC_AUDIO_Manager] saveAudioData:audio];
    
    ///播放
    [self playSoundWithUrlString:url isLocalFile:NO andFileName:@""];
    ///缓存
    [AFSoundPlaybackHelper downloadAndSave:url];
}


///播放本地音频
-(void)playVoiceByLocalFile:(NSString *)voiceStr {
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
        [self playSoundWithUrlString:audio.audio_path isLocalFile:YES andFileName:audio.audio_name];
        
    }else{
        ///不存在
        NSLog(@"本地文件播放时不存在  url播放并做缓存");
        [self audioNotExists:voiceStr];
    }
}


#pragma mark 播放音频
- (void)playSoundWithUrlString:(NSString*)urlString isLocalFile:(BOOL) isLocal andFileName:(NSString *)fileName{
    NSLog(@"playSoundWithUrlString 播放:%@",urlString);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        AFSoundItem *item;
        if(isLocal){
            item = [[AFSoundItem alloc] initWithLocalResource:fileName atPath:urlString];
        }else{
            item = [[AFSoundItem alloc] initWithStreamingURL:[NSURL URLWithString:urlString]];
        }
        
        [AFSoundPlaybackHelper setAFSoundPlaybackHelper:[[AFSoundPlayback alloc] initWithItem:item]];
        
        [AFSoundPlaybackHelper play_helper];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AFSoundPlaybackHelper getAFSoundPlaybackHelper] listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
                NSLog(@"Item duration: %ld - time timePlayed: %ld", (long)item.duration, (long)item.timePlayed);
                ///总时长-已播放时长
                curPlayAtSecond = item.timePlayed;
                if (item.timePlayed == 0) {
                    curTotalDuration = item.duration;
                    self.labelCurrentTime.text = @"正在缓冲";
                    self.labelTotleTime.text = [CommonFunc getMinutString:(int)item.duration intervalType:1 mode:1];
                }else{
                    [self.playingProcessBar setPlayingProcess:((item.timePlayed*1000)/item.duration)*0.001];
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    if (item.duration > 60*60) {
                        [formatter setDateFormat:@"HH:mm:ss"];
                    }
                    else {
                        [formatter setDateFormat:@"00:mm:ss"];
                    }
                    
                    NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:item.timePlayed];
                    self.labelCurrentTime.text = [formatter stringFromDate:elapsedTimeDate];
                }
                
            } andFinishedBlock:^(void){
                NSLog(@"andFinishedBlock");
                ///播放完成
                self.btnPlay.selected = NO;
                [self stopPlay];
            }];
        });
    });
}


- (void)stopPlay {
    
    if (!isPlaying) {
        return;
    }
    
    [AFSoundPlaybackHelper stop_helper];
    
    [self.playingProcessBar removeFromSuperview];
    self.playingProcessBar = [[PlayingProcessBar alloc] initWithFrame:CGRectMake(40, 0, 150+DEVICE_BOUNDS_WIDTH-320, 50) processBarBackgroundColor:nil processBarCoverColor:nil processBarHeightOccupy:0.13 cursorImageView:nil];
    [self.contentView  addSubview:self.playingProcessBar];
    
    [self.playingProcessBar setProcess:0.0f];
    [self.playingProcessBar setUserInteractionEnabled:YES];
    self.playingProcessBar.delegate = self;
//    [self.playingProcessBar setPlayingProcess:0];
    
    
    self.labelCurrentTime.text = @"00:00:00";
    self.btnPlay.selected = NO;
    isPlaying = NO;
}

#pragma mark - 进度条调整
- (void)processBarDidBeginSlide {
    //    NSLog(@"processBarDidBeginSlide--->");
    [AFSoundPlaybackHelper pause_helper];
}

- (void)processBarDidEndSlide:(float)percentage {
    //    NSLog(@"processBarDidEndSlide---:%f",percentage);
    self.labelCurrentTime.text = @"正在缓冲";
    isPlaying = YES;
    
    if (self.btnPlay.selected) {
        //        NSLog(@"processBarDidEndSlide--正在播放->");
        //正在播放
        if ([AFSoundPlaybackHelper getAFSoundPlaybackHelper]) {
            if (curTotalDuration > 0) {
                //                NSLog(@"processBarDidEndSlide--接着播放-curTotalDuration:%ti  playAtSecond:%ti",curTotalDuration,[[NSString stringWithFormat:@"%.f",percentage*curTotalDuration] integerValue]);
                [AFSoundPlaybackHelper playAtSecond_helper:[[NSString stringWithFormat:@"%.f",percentage*curTotalDuration] integerValue]];
            }else{
                //                NSLog(@"processBarDidEndSlide--重新播放->");
                [AFSoundPlaybackHelper restart_helper];
            }
        }else{
            [self stopPlay];
        }
    }
    else {
        //        NSLog(@"processBarDidEndSlide---播放暂停>");
        //播放暂停
        if (voiceUrlString) {
            [self playAndCacheWithUrl:voiceUrlString];
        }
        else {
            [self prepareToPlayVoice];
        }
    }
    self.btnPlay.selected = YES;
}

#pragma mark - 获取cell height
+(CGFloat)getCellContentHeight:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    return 50;
}

@end
