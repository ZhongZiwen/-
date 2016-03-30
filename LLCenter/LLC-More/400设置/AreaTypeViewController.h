//
//  AreaTypeViewController.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface AreaTypeViewController : AppsBaseViewController

///导航还是座席
@property(nonatomic,strong)NSString *navigationOrSit;
@property(nonatomic,strong)NSString *navigationOrSitId;

///导航的地区策略(详情) 用于座席地区策略时 判断是否在范围内
@property(nonatomic,strong)NSDictionary *areaStrategyNavDic;

///地区策略
@property(nonatomic,strong)NSDictionary *areaStrategyData;

///是否需要对选择地区根据导航地区策略做判断
///开通IVR导航情况下需要判断  未开通不需判断   yes  no
@property(nonatomic,strong)NSString *flagOfNeedJudge;

@property (nonatomic, copy) void (^SelectAreaDoneBlock)(NSString *areaCode,NSString *areaName);

@end
