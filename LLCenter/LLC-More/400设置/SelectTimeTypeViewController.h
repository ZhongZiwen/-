//
//  SelectTimeTypeViewController.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface SelectTimeTypeViewController : AppsBaseViewController

///区分标记 用于区分是否是从添加导航页面过来  @"addnavi"
@property(nonatomic,strong)NSString *viewFromFlag;

///导航详情 或 座席详情
@property(nonatomic,strong)NSDictionary *detail;
///导航还是座席
@property(nonatomic,strong)NSString *navigationOrSit;
///导航ID
@property(nonatomic,strong)NSString *navigationId;

@property(nonatomic,strong)NSArray *arrayDefaultTime;

///是否需要对选择时间根据导航时间策略做判断
///开通IVR导航情况下需要判断  未开通不需判断   yes  no
@property(nonatomic,strong)NSString *flagOfNeedJudge;

///导航的时间策略(详情) 用于座席时间策略时 判断是否在范围内
@property(nonatomic,strong)NSDictionary *timeStrategyNavDic;

///时间类型
@property (nonatomic, copy) void (^TimeTypeBlock)(NSString *timeType);

///时间类型
@property (nonatomic, copy) void (^TimeTypeAddNaviBlock)(NSString *timeType,NSDictionary *newNaviInfo,NSDictionary *dicSelectedTimeType);

@end
