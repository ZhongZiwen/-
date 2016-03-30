//
//  TimeTypeViewController.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AppsBaseViewController.h"


@interface TimeTypeViewController : AppsBaseViewController

///导航还是座席
@property(nonatomic,strong)NSString *navigationOrSit;
@property(nonatomic,strong)NSString *navigationOrSitId;
@property(nonatomic,strong)NSArray *arrayDefaultTime;

///时间策略
@property(nonatomic,strong)NSDictionary *timeStrategyData;

///导航的时间策略(详情) 用于座席时间策略时 判断是否在范围内
@property(nonatomic,strong)NSDictionary *timeStrategyNavDic;

///是否需要对选择时间根据导航时间策略做判断
///开通IVR导航情况下需要判断  未开通不需判断   yes  no
@property(nonatomic,strong)NSString *flagOfNeedJudge;

@property (nonatomic, copy) void (^SelectDateTimeDoneBlock)(NSArray *appointTime,NSArray *startTime,NSArray *endTime);


@end
