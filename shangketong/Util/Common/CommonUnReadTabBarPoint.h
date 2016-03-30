//
//  CommonUnReadTabBarPoint.h
//  shanghketong
//
//  Created by sungoin-zjp on 15-12-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//




#import <Foundation/Foundation.h>

@interface CommonUnReadTabBarPoint : NSObject

///初始化红点
+(void)initTabbarIconView;
///根据返回码 控制红点的显示与隐藏
+(void)notifyTabBarItemUnReadIcon:(NSString *)modelCode;

@end
