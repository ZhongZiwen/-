//
//  NavigationSettingCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-20.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "NavigationSettingCell.h"
#import "LLCenterUtility.h"

@interface NavigationSettingCell() <UIAlertViewDelegate> {
    NSString *voiceUrlString;
    bool canPlay,isPlaying,isWifi;
    int soundDuration,watchDogCounter;
    
    
}


@end

@implementation NavigationSettingCell


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        NSLog(@"initWithCoder--->");
    }
    return self;
}

- (void)awakeFromNib {
    [self setCellFrame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(NSDictionary *)item andIndexPath:(NSIndexPath *)indexPath{
    /*
     childNavigationList(下级导航列表
     [childNavigationId 下级导航ID;
     childNavigationName 下级导航名称;
     childNavigationKeyPress 下级导航按键;
     childNavigationRing 下级导航彩铃;
     childNavigationRingUrl 下级导航彩铃URL;
     childNavigationHasChild 下级导航是否含有下级导航
     
     childNavigationHasChild = 1;
     childNavigationId = 11681180168;
     childNavigationKeyPress = 1;
     childNavigationName = Navigation;
     childNavigationRing = "<null>";
     childNavigationRingUrl = "";
     */
    NSString *name = @"";
    NSString *keyNum = @"";
    NSString *ringName = @"";
    
    if ([item objectForKey:@"childNavigationName"]) {
        name = [item safeObjectForKey:@"childNavigationName"];
    }
    
    if ([item objectForKey:@"childNavigationKeyPress"]) {
        keyNum = [item safeObjectForKey:@"childNavigationKeyPress"];
    }
    
    if ([item objectForKey:@"childNavigationRing"]) {
        ringName = [item safeObjectForKey:@"childNavigationRing"];
    }
    
    self.labelNavigationName.text = name;
    self.labelNumKey.text = keyNum;
    self.labelRingName.text = ringName;
    
    
    self.btnPlay.tag = indexPath.row;
    [self.btnPlay addTarget:self action:@selector(playRing:) forControlEvents:UIControlEventTouchUpInside];
    
    ///url为空则隐藏播放按钮
    self.btnPlay.hidden = YES;
    if (([item objectForKey:@"childNavigationRingUrl"] && [item safeObjectForKey:@"childNavigationRingUrl"].length > 0) && ([item objectForKey:@"childNavigationRing"] && [item safeObjectForKey:@"childNavigationRing"].length > 0)) {
        self.btnPlay.hidden = NO;
    }
}


///播放铃声
- (void)playRing:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSLog(@"index %ti",btn.tag);
    if (self.PlayRingBlock) {
        self.PlayRingBlock(btn.tag);
    }
}

-(void)ssss{
    
}


-(void)setCellFrame{
    NSInteger wd = (DEVICE_BOUNDS_WIDTH-320)/2;
    self.labelNavigationName.frame = CGRectMake(15, 15, 90+wd, 20);
    self.labelNumKey.frame = CGRectMake(115+wd, 15, 60, 20);
    self.labelRingName.frame =CGRectMake(175+wd, 15, 95+wd, 20);
    self.btnPlay.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-40, 12, 25, 25);
}


- (void)playSoundWithUrlString:(NSString*)urlString {
    NSLog(@"playSoundWithUrlString 播放:%@",urlString);
    if ([urlString isEqualToString:@""]) {
        
        return;
    }
    
   
}


- (void)stopPlay{
    
}


@end
