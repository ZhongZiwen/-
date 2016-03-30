//
//  CallListCell.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-22.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "CallListCell.h"
#import "AFSoundPlaybackHelper.h"
#import "UserSession.h"
#import "Reachability.h"
//#import "SettingViewController.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "NSString+Common.h"
#import "Reachability.h"
#import "FMDB_LLC_AUDIO.h"
#import "LLCAudioCache.h"

@interface CallListCell ()<UIAlertViewDelegate,PlayingProcessBarDelegate> {
    NSString *voiceUrlString;
    CellDataInfo *cellInfo;
    bool canPlay,isPlaying,isWifi;
    int soundDuration,watchDogCounter;
    float moveToPlayingPercentage,currentPlayingPercentage;
    
    ///当前播放进度
    NSInteger curPlayAtSecond;
    ///当前音频总时长
    NSInteger curTotalDuration;
}

@end

@implementation CallListCell
@synthesize cellType,nvController,delegate,indexPath;


//-(NSString *)getDateWith:(NSString *)date
//{
//    NSDateFormatter* formate=[[NSDateFormatter alloc]init];
//    [formate setDateFormat:DATE_FORMAT_SPLIT];
//    [formate setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//    [formate stringFromDate:date]
//    
//}



-(NSString *)getFormatString:(NSString *)m_time{
    NSString *strResult = @"";
    
    NSInteger value = [CommonFuntion getTimeDaysSinceToady:m_time];
    if (value == 0) {
        strResult = [m_time substringWithRange:NSMakeRange(11, 5)];
    } else if (value == 1) {
        strResult = @"昨天";
    } else if (value > 1 && value <=7) {
        NSArray *weekDaysArray = @[@"星期日", @"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
        NSDateFormatter* formate=[[NSDateFormatter alloc]init];
        [formate setDateFormat:@"yyyy-MM-dd HH:mm"];
        [formate setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formate dateFromString:m_time];
        
        NSLog(@"date date:%@",[formate dateFromString:m_time]);
        NSInteger index = [CommonFuntion getCurDateWeekday:[formate dateFromString:m_time]];
        strResult = [weekDaysArray objectAtIndex:index - 1];
    } else {
        strResult = [m_time substringToIndex:10];
    }
    return strResult;
}

- (void)setCellDataInfo:(CellDataInfo*)cInfo {
    //
    [self setShowFormat:cellType andDateInfo:cInfo];
    
    labelTitle.text = @"";
    labelSubTitle.text = @"";
    labelDate.text = @"";
    labelCallTimeContent.text = @"";
    labelCustomerPhoneContent.text = @"";
    labelRecieverContent.text = @"";
    labelDurationContent.text = @"";
    labelTotleTime.text = @"";
    labelSit.text = @"";
    
    ///左上第一行 021-xxxxx
    cellInfo = cInfo;
//    if ([cInfo.cellDataInfo objectForKey:@"titleName"] && [[cInfo.cellDataInfo objectForKey:@"titleName"] isKindOfClass:[NSString class]]) {
        labelTitle.text = [cInfo.cellDataInfo safeObjectForKey:@"titleName"];
//    }
    ///左上第一行  上海市
//    if ([cInfo.cellDataInfo objectForKey:@"subTitleName"] && [[cInfo.cellDataInfo objectForKey:@"subTitleName"] isKindOfClass:[NSString class]]) {
//    NSLog(@"subTitleName:%@",[cInfo.cellDataInfo safeObjectForKey:@"subTitleName"]);
        labelSubTitle.text = [cInfo.cellDataInfo safeObjectForKey:@"subTitleName"];
//    }
    ///日期
//    if ([cInfo.cellDataInfo objectForKey:@"time"] && [[cInfo.cellDataInfo objectForKey:@"time"] isKindOfClass:[NSString class]]) {
    
    NSString *datetime = @"";
    
//    if (cellType != CallListCellOutCall) {
//        datetime = [CommonFunc formatDisplayDateString:[cInfo.cellDataInfo safeObjectForKey:@"time"]];
//    }else{
//        datetime = [cInfo.cellDataInfo safeObjectForKey:@"time"];
//    }
    
    datetime = [cInfo.cellDataInfo safeObjectForKey:@"time"];
    NSLog(@"date0:%@",datetime);
//    NSLog(@"datetime:%@",datetime);
    if (datetime && ![datetime isEqualToString:@""]) {

        /*
        NSDate *date = [CommonFunc stringToDateNoTimeZone:datetime withFormat:@"yyyy-MM-dd HH:mm"];
//        NSLog(@"date:%@",date);
            NSLog(@"date2:%@",date);
        NSDateFormatter* formate=[[NSDateFormatter alloc]init];
        [formate setDateFormat:@"yyyy-MM-dd HH:mm"];
        [formate setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formate dateFromString:datetime];
        [formate stringFromDate:date];
         NSLog(@"date str:%@",[formate stringFromDate:date]);
        NSLog(@"date date:%@",[formate dateFromString:datetime]);
        
        
        
        labelDate.text = [NSString msgRemindTransDateWithDate:[formate dateFromString:datetime]];
        NSLog(@"date3:%@",labelDate.text);
         */
        
        labelDate.text = [self getFormatString:datetime];
    }
    
    
//    }
    
    labelRecieverContent.text = [cInfo.cellDataInfo safeObjectForKey:@"sitName"];
    
    
    ///外呼记录
    if (cellType == CallListCellOutCall) {
        ///外呼记录  手机号
        
        if ([[cInfo.cellDataInfo safeObjectForKey:@"customerPhone"] isEqualToString:@""]) {
            labelSit.text = @"";
            callIcon.hidden = YES;
        }else{
            labelSit.text = [NSString stringWithFormat:@"%@",[cInfo.cellDataInfo safeObjectForKey:@"customerPhone"]];
            callIcon.hidden = NO;
        }
        
        /*
        if ([cInfo.cellDataInfo objectForKey:@"customerPhone"] && [[cInfo.cellDataInfo objectForKey:@"customerPhone"] isKindOfClass:[NSString class]]) {
            
            
            if ([cInfo.cellDataInfo objectForKey:@"customerPhone"] == nil  || [[cInfo.cellDataInfo objectForKey:@"customerPhone"] isEqualToString:@"<null>"] || [[cInfo.cellDataInfo objectForKey:@"customerPhone"] isEqualToString:@""]) {
                labelSit.text = @"";
                callIcon.hidden = YES;
            }else{
                labelSit.text = [NSString stringWithFormat:@"%@",[cInfo.cellDataInfo safeObjectForKey:@"customerPhone"]];
                callIcon.hidden = NO;
            }
        }
         */
    }

    ///未接来电
    if (cellType == CallListCellNoAnswer) {
        
        ///归属座席
        if ([[cInfo.cellDataInfo safeObjectForKey:@"sitName"] isEqualToString:@""]) {
            labelSit.text = @"";
        }else{
            labelSit.text = [NSString stringWithFormat:@"归属坐席:%@",[cInfo.cellDataInfo safeObjectForKey:@"sitName"]];
        }
        
        /*
        if ([cInfo.cellDataInfo objectForKey:@"sitName"] && [[cInfo.cellDataInfo objectForKey:@"sitName"] isKindOfClass:[NSString class]]) {
            ///接听座席
            labelRecieverContent.text = [cInfo.cellDataInfo safeObjectForKey:@"sitName"];
            
            //        NSLog(@"siteName:%@",[cInfo.cellDataInfo objectForKey:@"sitName"]);
            
            ///归属座席
            if ([cInfo.cellDataInfo objectForKey:@"sitName"] == nil  || [[cInfo.cellDataInfo objectForKey:@"sitName"] isEqualToString:@"<null>"] || [[cInfo.cellDataInfo objectForKey:@"sitName"] isEqualToString:@""]) {
                labelSit.text = @"";
            }else{
                labelSit.text = [NSString stringWithFormat:@"归属坐席:%@",[cInfo.cellDataInfo safeObjectForKey:@"sitName"]];
            }
        }
         */
    }
    
    ///总时长
    if ([cInfo.cellDataInfo objectForKey:@"duration"] ) {
        labelDurationContent.text = [CommonFunc getMinutString:[[NSString stringWithFormat:@"%@",[cInfo.cellDataInfo safeObjectForKey:@"duration"]] intValue] intervalType:cellType mode:0];
        
        labelTotleTime.text = [CommonFunc getMinutString:[[NSString stringWithFormat:@"%@",[cInfo.cellDataInfo safeObjectForKey:@"duration"]] intValue] intervalType:1 mode:1];
    }
    
//    labelDate.text = [self formatDisplayDateString:[cInfo.cellDataInfo objectForKey:@"time"]];
//    
//    labelCustomerPhoneContent.text = [cInfo.cellDataInfo objectForKey:@"customerPhone"];
//    labelCallTimeContent.text = [cInfo.cellDataInfo objectForKey:@"time"];
//    labelRecieverContent.text = [cInfo.cellDataInfo objectForKey:@"sitName"];
//    labelDurationContent.text = [self getMinutString:[[NSString stringWithFormat:@"%@",[cInfo.cellDataInfo objectForKey:@"duration"]] intValue] mode:0];
//    labelTotleTime.text = [self getMinutString:[[NSString stringWithFormat:@"%@",[cInfo.cellDataInfo objectForKey:@"duration"]] intValue] mode:1];
//
    
    ///展开图标
    btnExpand.selected = cInfo.expanded;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
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
    
    
    CGRect expandedRect = expandedView.frame;
    expandedRect.origin.y = self.frame.size.height;
    expandedView.frame = expandedRect;
    [self.contentView addSubview:expandedView];
    
//    NSLog(@"init - cell -- %d",cellInfo.expanded);
    if ([playingProcessBar isDescendantOfView:expandedViewButtom]) {
        [playingProcessBar removeFromSuperview];
        playingProcessBar = [[PlayingProcessBar alloc] initWithFrame:CGRectMake(100, 60, 170+DEVICE_BOUNDS_WIDTH-320, 50) processBarBackgroundColor:nil processBarCoverColor:nil processBarHeightOccupy:0.13 cursorImageView:nil];
    }
    else {
        playingProcessBar = [[PlayingProcessBar alloc] initWithFrame:CGRectMake(100, 60, 170+DEVICE_BOUNDS_WIDTH-320, 50) processBarBackgroundColor:nil processBarCoverColor:nil processBarHeightOccupy:0.13 cursorImageView:nil];
    }
    [expandedViewButtom addSubview:playingProcessBar];
    [playingProcessBar setProcess:0.0f];
    [playingProcessBar setUserInteractionEnabled:YES];
    playingProcessBar.delegate = self;
    
    [playingProcessBar setPlayingProcess:0];
    NSDictionary *playInfo = [cellInfo.cellDataInfo objectForKey:@"PlayInfo"];
    if (playInfo) {
        NSLog(@"%@",playInfo);
        float pPercetage = [[playInfo objectForKey:@"percentage"] floatValue];
        [playingProcessBar setPlayingProcess:pPercetage];
        isPlaying = [[playInfo safeObjectForKey:@"playing"] boolValue];
    }
    
    if (cInfo.expanded) {
        triangleImageView.hidden = NO;
    }
    else {
        triangleImageView.hidden = YES;
        [self stopPlay];
    }
    
//    UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGuesture:)];
//    recognizer1.direction = UISwipeGestureRecognizerDirectionRight;
//    [self addGestureRecognizer:recognizer1];
//    
//    UISwipeGestureRecognizer *recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGuesture:)];
//    recognizer2.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self addGestureRecognizer:recognizer2];
}




//- (NSString*)getMinutString:(int)interval mode:(int)mode {
//    int hour = interval / 60;
//    int min = interval % 60;
//    if (hour > 0) {
//        if (mode == 0) {
//            return [NSString stringWithFormat:@"%d时%d分",hour,min];
//        }
//        else {
//            return [NSString stringWithFormat:@"%02d:%02d:00",hour,min];
//        }
//    }
//    else {
//        if (mode == 0) {
//            return [NSString stringWithFormat:@"%d分",min];
//        }
//        else {
//            return [NSString stringWithFormat:@"00:%02d:00",min];
//        }
//    }
//}

- (void)setShowFormat:(int)f andDateInfo:(CellDataInfo*)cInfo{
    if (f == CallListCellAnswered) {
        //已接来电 -- 默认
        labelRecieverTitle.hidden = NO;
        labelRecieverContent.hidden = NO;
        labelDurationTitle.frame = CGRectMake(190+DEVICE_BOUNDS_WIDTH-320, 2, 70, 20);
        labelDurationContent.frame = CGRectMake(260+DEVICE_BOUNDS_WIDTH-320, 2, 80, 20);
        
        ///隐藏归属座席
        labelSit.hidden = YES;
        ///隐藏电话图标
        callIcon.hidden = YES;
        
        btnCallByPhoneNum.hidden = NO;
        btnExpAction.hidden = NO;
        btnExpand.hidden = NO;
        labelDate.textAlignment = NSTextAlignmentRight;
        labelDate.frame = CGRectMake(170+DEVICE_BOUNDS_WIDTH-320, 20, 100, 20);
        
        NSString *subTitleName = [cInfo.cellDataInfo safeObjectForKey:@"subTitleName"];
        if ([subTitleName isEqualToString:@""]) {
            labelTitle.frame = CGRectMake(28, 20, 180, 20);
//            labelSubTitle.frame = CGRectMake(28, 35, 180, 20);
        }else{
            labelTitle.frame = CGRectMake(28, 7, 180, 20);
            labelSubTitle.frame = CGRectMake(28, 35, 180, 20);
        }
    }
    else if (f == CallListCellNoAnswer) {
        //未接来电 -- 默认
//        labelRecieverTitle.text = @"归属坐席:";
        
        ///归属座席
        labelSit.hidden = NO;
        ///电话图标
        callIcon.hidden = NO;
        btnCallByPhoneNum.hidden = YES;
        btnExpAction.hidden = NO;
        btnExpand.hidden = YES;
        labelDate.textAlignment = NSTextAlignmentCenter;
        labelSit.textAlignment = NSTextAlignmentCenter;
        labelDate.frame = CGRectMake(155+DEVICE_BOUNDS_WIDTH-320, 8, 120, 20);
        labelSit.frame = CGRectMake(155+DEVICE_BOUNDS_WIDTH-320, 35, 120, 20);
        callIcon.frame = CGRectMake(280+DEVICE_BOUNDS_WIDTH-320, 20, 24, 21);
        
        NSString *subTitleName = [cInfo.cellDataInfo safeObjectForKey:@"subTitleName"];
        if ([subTitleName isEqualToString:@""]) {
            labelTitle.frame = CGRectMake(28, 20, 180, 20);
            //            labelSubTitle.frame = CGRectMake(28, 35, 180, 20);
        }else{
            labelTitle.frame = CGRectMake(28, 7, 180, 20);
            labelSubTitle.frame = CGRectMake(28, 35, 180, 20);
        }
        
        
        NSString *sitName =[cInfo.cellDataInfo safeObjectForKey:@"sitName"] ;
        if ([sitName isEqualToString:@""]) {
            labelDate.frame = CGRectMake(170+DEVICE_BOUNDS_WIDTH-320, 20, 100, 20);
        }else{
            labelDate.frame = CGRectMake(155+DEVICE_BOUNDS_WIDTH-320, 8, 120, 20);
            labelSit.frame = CGRectMake(155+DEVICE_BOUNDS_WIDTH-320, 35, 120, 20);
        }
        
        
    }else if (f == CallListCellOutCall) {
        ///外呼记录
        
        labelSit.hidden = NO;
        ///电话图标
        callIcon.hidden = NO;
        
        btnCallByPhoneNum.hidden = YES;
        btnExpAction.hidden = NO;
        btnExpand.hidden = YES;
        labelDate.textAlignment = NSTextAlignmentCenter;
        labelSit.textAlignment = NSTextAlignmentCenter;
        labelDate.frame = CGRectMake(155+DEVICE_BOUNDS_WIDTH-320, 8, 120, 20);
        labelSit.frame = CGRectMake(155+DEVICE_BOUNDS_WIDTH-320, 35, 120, 20);
        callIcon.frame = CGRectMake(280+DEVICE_BOUNDS_WIDTH-320, 20, 24, 21);
        
        NSString *titleName = [cInfo.cellDataInfo safeObjectForKey:@"titleName"];
        NSString *subTitleName = [cInfo.cellDataInfo safeObjectForKey:@"subTitleName"];
        NSString *time = [cInfo.cellDataInfo safeObjectForKey:@"time"];
        
        if ([titleName isEqualToString:@""] && ![subTitleName isEqualToString:@""]) {
            labelSubTitle.frame = CGRectMake(28, 20, 180, 20);
        }else if (![titleName isEqualToString:@""] && [subTitleName isEqualToString:@""]) {
            labelTitle.frame = CGRectMake(28, 20, 180, 20);
        }else if ([titleName isEqualToString:@""] && [subTitleName isEqualToString:@""]) {
            labelSit.textAlignment = NSTextAlignmentLeft;
            labelSit.font = [UIFont systemFontOfSize:16.0];
            if ([time isEqualToString:@""]) {
                labelSit.frame = CGRectMake(28, 20, 180, 20);;
            }else{
                labelSit.frame = CGRectMake(28, 20, 180, 20);;
                labelDate.frame = CGRectMake(155+DEVICE_BOUNDS_WIDTH-320, 20, 120, 20);
            }
            
        }else if ([time isEqualToString:@""]){
            
            labelSit.frame = CGRectMake(155+DEVICE_BOUNDS_WIDTH-320, 20, 120, 20);
        }
        
        
    }
    else if (f == CallListCellVoiceBox) {
        //语音信箱
        labelCallTimeTitle.text = @"留言时间:";
        labelDurationTitle.text = @"留言时长:";
        labelAuditionTitle.text = @"留言试听:";
        
        ///隐藏归属坐席
        labelSit.hidden = YES;
        ///隐藏电话图标
        callIcon.hidden = YES;
        btnCallByPhoneNum.hidden = NO;
        btnExpAction.hidden = NO;
        btnExpand.hidden = NO;
        labelDate.textAlignment = NSTextAlignmentRight;
        labelDate.frame = CGRectMake(170+DEVICE_BOUNDS_WIDTH-320, 20, 100, 20);
        
        labelRecieverTitle.hidden = YES;
        labelRecieverContent.hidden = YES;
        labelDurationTitle.hidden = NO;
        labelDurationContent.hidden = NO;
        labelDurationTitle.frame = CGRectMake(28, 2, 70, 20);
        labelDurationContent.frame = CGRectMake(100, 2, 80, 20);
        
        CGRect bRect = expandedViewButtom.frame;
//        bRect.origin.y = 93.0f;
        expandedViewButtom.frame = bRect;
        
        NSString *subTitleName = [cInfo.cellDataInfo safeObjectForKey:@"subTitleName"];
        if ([subTitleName isEqualToString:@""]) {
            labelTitle.frame = CGRectMake(28, 20, 180, 20);
            //            labelSubTitle.frame = CGRectMake(28, 35, 180, 20);
        }else{
            labelTitle.frame = CGRectMake(28, 7, 180, 20);
            labelSubTitle.frame = CGRectMake(28, 35, 180, 20);
        }
    }
}

- (void)setButtonSelected:(bool)isSelected {
    btnExpand.selected = isSelected;
    triangleImageView.hidden = !isSelected;
    [self stopPlay];
}


- (void)prepareToPlayVoice {
//    if (cellType == CallListCellAnswered) {
//        voiceUrlString = @"http://180.166.192.27:9080/headserver/temp/02153892286_190622.wav";
//    }
//    else {
//        voiceUrlString = @"http://180.166.192.27:9080/headserver/temp/2014061317392202153892286.wav";
//    }
//    
//    [self playSoundWithUrlString:voiceUrlString];
//    return;
    
    if (voiceUrlString && voiceUrlString.length > 0) {
        [self playAndCacheWithUrl:voiceUrlString];
    }
    else {
        [self getVoice];
    }
}


-(void)getVoice{
    NSString *action = LLC_GET_VOICE_URL_ACTION;
    if (cellType == CallListCellVoiceBox) {
        action = LLC_GET_LISTEN_BOX_URL_ACTION;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   [cellInfo.cellDataInfo safeObjectForKey:@"platform"],@"platform",
                                   [cellInfo.cellDataInfo safeObjectForKey:@"lsh"],@"lsh",nil];
    NSLog(@"params:%@",params);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,action] params:params success:^(id jsonResponse) {
        
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
            
            labelCurrentTime.text = @"00:00:00";
            btnPlay.selected = NO;
        }
        
        
    } failure:^(NSError *error) {
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.contentView];
        labelCurrentTime.text = @"00:00:00";
        btnPlay.selected = NO;
    }];
}

- (IBAction)btnAction:(id)sender {
    
    btnPlay.selected = !btnPlay.selected;
    if (btnPlay.selected) {
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
            labelCurrentTime.text = @"正在缓冲";
            if (voiceUrlString) {
                [self playAndCacheWithUrl:voiceUrlString];
            }else {
//                [SVProgressHUD showErrorWithStatus:@"播放出错!"];
//                labelCurrentTime.text = @"00:00:00";
//                return;
                [self prepareToPlayVoice];
            }
            
        }
        else {
            //播放到一半
            [AFSoundPlaybackHelper playAtSecond_helper:curPlayAtSecond];
        }
        
    }
    else {
        //进入暂停状态
        [AFSoundPlaybackHelper pause_helper];
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
-(void)playVoiceByLocalFile:(NSString *)voiceStr{
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
                    labelCurrentTime.text = @"正在缓冲";
                    labelTotleTime.text = [CommonFunc getMinutString:(int)item.duration intervalType:1 mode:1];
                }else{
                    [playingProcessBar setPlayingProcess:((item.timePlayed*1000)/item.duration)*0.001];
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    if (item.duration > 60*60) {
                        [formatter setDateFormat:@"HH:mm:ss"];
                    }
                    else {
                        [formatter setDateFormat:@"00:mm:ss"];
                    }
                    
                    NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:item.timePlayed];
                    labelCurrentTime.text = [formatter stringFromDate:elapsedTimeDate];
                }
                
            } andFinishedBlock:^(void){
                NSLog(@"andFinishedBlock");
                ///播放完成
                btnPlay.selected = NO;
                [self stopPlay];
            }];
        });
    });
}


#pragma mark  停止播放
- (void)stopPlay {
    if (!isPlaying) {
        return;
    }
    
    [AFSoundPlaybackHelper stop_helper];
    
    if ([playingProcessBar isDescendantOfView:expandedViewButtom]) {
        [playingProcessBar removeFromSuperview];
        playingProcessBar = [[PlayingProcessBar alloc] initWithFrame:CGRectMake(100, 60, 170+DEVICE_BOUNDS_WIDTH-320, 50) processBarBackgroundColor:nil processBarCoverColor:nil processBarHeightOccupy:0.13 cursorImageView:nil];
    }
    else {
        playingProcessBar = [[PlayingProcessBar alloc] initWithFrame:CGRectMake(100, 60, 170+DEVICE_BOUNDS_WIDTH-320, 50) processBarBackgroundColor:nil processBarCoverColor:nil processBarHeightOccupy:0.13 cursorImageView:nil];
    }
    [expandedViewButtom addSubview:playingProcessBar];
    [playingProcessBar setProcess:0.0f];
    [playingProcessBar setUserInteractionEnabled:YES];
    playingProcessBar.delegate = self;
    
    labelCurrentTime.text = @"00:00:00";
    btnPlay.selected = NO;
    isPlaying = NO;
}

#pragma mark - 进度条调整
- (void)processBarDidBeginSlide {
    //    NSLog(@"processBarDidBeginSlide--->");
    [AFSoundPlaybackHelper pause_helper];
}

- (void)processBarDidEndSlide:(float)percentage {
    //    NSLog(@"processBarDidEndSlide---:%f",percentage);
    labelCurrentTime.text = @"正在缓冲";
    isPlaying = YES;
    
    if (btnPlay.selected) {
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
    btnPlay.selected = YES;
}


- (IBAction)expandButtonAction:(id)sender {
    if ([delegate respondsToSelector:@selector(expandButtonAction:object:)]) {
        [delegate expandButtonAction:indexPath object:cellInfo];
    }
}


-(IBAction)callIt:(id)sender{
    if ([delegate respondsToSelector:@selector(callPhone:object:)]) {
        [delegate callPhone:indexPath object:cellInfo];
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
//        canPlay = YES;
//        [self btnAction:btnPlay];
//        SettingViewController *sVc = [[SettingViewController alloc] init];
//        [nvController pushViewController:sVc animated:YES];
    }
}

#pragma mark - 截取父类的触摸事件
- (void)handleSwipeGuesture:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"slide.....");
}





// UI 适配
-(void)setCellViewFrame
{
    if (DEVICE_IS_IPHONE6) {
        
        [self setViewFrameFor6];
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
        [self setViewFrameFor6];
    }else if(!DEVICE_IS_IPHONE5)
    {
        
    }else
    {
        
    }
}

-(void)setViewFrameFor6
{
//    NSLog(@"--setViewFrameFor6-->");
    NSInteger vX = DEVICE_BOUNDS_WIDTH-320;

    view_line.frame = [CommonFunc setViewFrameOffset:view_line.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
//    labelDate.frame = [CommonFunc setViewFrameOffset:labelDate.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    btnExpand.frame = [CommonFunc setViewFrameOffset:btnExpand.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    btnExpAction.frame = [CommonFunc setViewFrameOffset:btnExpAction.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    triangleImageView.frame = [CommonFunc setViewFrameOffset:triangleImageView.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
    
    // exp
    expandedView.frame = [CommonFunc setViewFrameOffset:expandedView.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    expandedViewButtom.frame = [CommonFunc setViewFrameOffset:expandedViewButtom.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    labelTotleTime.frame = [CommonFunc setViewFrameOffset:labelTotleTime.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
}


@end
