//
//  ReleaseToolView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReleaseToolView : UIView

@property (nonatomic, copy) void(^locationBlock)(void);
@property (nonatomic, copy) void(^privateBlock)(void);
@property (nonatomic, copy) void(^toolSelectedBlock)(NSInteger);

@property (nonatomic, copy) NSString *locationBtnTitle;
@property (nonatomic, copy) NSString *privateBtnTitle;

///时长
@property (nonatomic, assign) float durationVoice;
-(void)notifyVoiceView;
@property (nonatomic, copy) void (^RecordingBlock)(NSString *filePath,NSString *fileName);

@end
