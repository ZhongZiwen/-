//
//  WeatherInfo.h
//  shangketong
//  天气信息
//  Created by sungoin-zjp on 15-6-2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherInfo : NSObject

///根据城市名称获取其天气信息
+(void)getWeatherInfosByCityName:(NSString *)cityName;

@end
