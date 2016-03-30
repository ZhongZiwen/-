//
//  LLCenterUtility.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 14-12-10.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <Foundation/Foundation.h>


// 当前设备width
#define DEVICE_BOUNDS_WIDTH ([[UIScreen mainScreen] bounds].size.width)
// 当前设备height
#define DEVICE_BOUNDS_HEIGHT ([[UIScreen mainScreen] bounds].size.height)


#define VERSION_CODE 127
//iOS版本
#define iOSVersion [[UIDevice currentDevice] systemVersion]
//app版本号
#define LLCenterVersion @"1.2.7"

//#define LLCenterVersion [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]

#define URL_APPATORE @"https://itunes.apple.com/cn/app/shang-ke-tong/id908677026?l=zh&ls=1&mt=8"


// NSUserDefaults 标记key
// --增加席座  接听席座 jieting  外呼席座 waihu
#define SWITCH_JIETING_KEY @"jieting"
#define SWITCH_WAIHU_KEY @"waihu"

#define VIEW_BG_COLOR [UIColor colorWithRed:239.0f/255 green:239.0f/255 blue:244.0f/255 alpha:1.0f]

#define CUSTOMER_DETAIL_VIEW_BG_COLOR [UIColor colorWithRed:230.0f/255 green:230.0f/255 blue:230.0f/255 alpha:1.0f]

#pragma mark -   label宽度与高度max
#define MAX_WIDTH_OR_HEIGHT 2999

#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

//用来标记在BecomeActive方法里是否检查版本信息 0 不需要 1需要
NSInteger flagOfBecomeActive;
//用来标记是否点击了alert里的按钮  点击了1  未点击2
NSInteger flagOfUpdateVersion;

// ---备注 NSUserDefaults   key--isNeedCheckVersion 是否需要检测版本 非强制更新选择取消时则不再检测

///是否有新版本
BOOL isNewVersion;


@interface LLCenterUtility : NSObject


@end
