//
//  SelectAreaTypeViewController.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface SelectAreaTypeViewController : AppsBaseViewController

///区分标记 用于区分是否是从添加导航页面过来  @"addnavi"
@property(nonatomic,strong)NSString *viewFromFlag;

///导航详情 或 座席详情
@property(nonatomic,strong)NSDictionary *detail;
///导航的地区策略(详情) 用于座席地区策略时 判断是否在范围内
@property(nonatomic,strong)NSDictionary *areaStrategyNavDic;
///导航还是座席
@property(nonatomic,strong)NSString *navigationOrSit;
@property(nonatomic,strong)NSString *navigationId;
@property(nonatomic,strong)NSArray *arrayDefaultArea;

///是否需要对选择地区根据导航地区策略做判断
///开通IVR导航情况下需要判断  未开通不需判断   yes  no
@property(nonatomic,strong)NSString *flagOfNeedJudge;

///地区类型
@property (nonatomic, copy) void (^AreaTypeBlock)(NSString *areaType);

///地区类型
@property (nonatomic, copy) void (^AreaTypeAddNaviBlock)(NSString *areaType,NSDictionary *newNaviInfo,NSDictionary *dicSelectedAreaType);

@end
