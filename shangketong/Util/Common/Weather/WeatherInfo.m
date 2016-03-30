//
//  WeatherInfo.m
//  shangketong
//  
//  Created by sungoin-zjp on 15-6-2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//


/*
 百度天气
 http://apistore.baidu.com/apiworks/servicedetail/112.html
 */


//#define URL_WEATHER @"http://m.weather.com.cn/atad/"
//#define URL_WEATHER @"http://www.weather.com.cn/adat/sk/"
#define URL_WEATHER @"http://apis.baidu.com/apistore/weatherservice/cityname"
#define KEY_WEATHER @"a67ef43524873bd0d1c18e75451a424f"

#import "WeatherInfo.h"
#import "AFHTTPRequestOperationManager.h"

@implementation WeatherInfo


///根据城市名称获取城市代码
+(NSString *)getCityCodeByName:(NSString *)cityName{
    __block  NSString *code = @"";
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CityCode" ofType:@"plist"];
    NSMutableArray *arrayCityCode = [[NSMutableArray alloc] initWithCapacity:0];
    [arrayCityCode addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:plistPath]];

    [arrayCityCode enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL  *stop){
        ///匹配到城市
        if([cityName rangeOfString:[obj objectForKey:@"key"]].location !=NSNotFound)
        {
            code = [obj objectForKey:@"value"];
            //终断循环
            *stop = YES;
        }
    }];
    return code;
}


+(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg  {
    
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
//    NSString *unicodeStr = [NSString stringWithCString:[urlStr UTF8String] encoding:NSUnicodeStringEncoding];
    NSURL * nurl=[[NSURL alloc] initWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"nurl:%@",nurl);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: nurl cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: KEY_WEATHER forHTTPHeaderField: @"apikey"];
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               } else {
                                    //转换数据格式
                                   NSDictionary *content = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//                                   NSLog(@"content %@",content);
//                                   NSLog(@"errMsg %@",[content safeObjectForKey:@"errMsg"]);
                                   
                                   ///消息体
                                   if(content){
                                       NSMutableDictionary *weatherInfo = [[NSMutableDictionary alloc] init];
                                       NSDictionary *infos = [content objectForKey:@"retData"];
                                       if (infos) {
                                           ///气温℃
                                           [weatherInfo setObject:[NSString stringWithFormat:@"%@℃~%@℃",[infos safeObjectForKey:@"l_tmp"],[infos safeObjectForKey:@"h_tmp"]] forKey:@"temperature"];
                                           ///天气
                                           [weatherInfo setObject:[infos safeObjectForKey:@"weather"] forKey:@"weather"];
                                           ///通知刷新UI显示
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"weather_infos" object:weatherInfo];
                                       }
                                   }
                               }
                           }];
}


///根据城市名称获取其天气信息
+(void)getWeatherInfosByCityName:(NSString *)cityName{
    NSString *httpArg =[NSString stringWithFormat:@"cityname=%@",cityName];
    
    [self request:URL_WEATHER withHttpArg:httpArg];
    
    return;
        
    NSMutableDictionary *weatherInfo = [[NSMutableDictionary alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@?%@",URL_WEATHER,httpArg];
    NSLog(@"url:%@",url);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置请求参数的格式：JSON格式
    manager.requestSerializer =  [AFJSONRequestSerializer serializer];
    // 设置返回数据的解析方式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:KEY_WEATHER forHTTPHeaderField:@"apikey"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"天气信息: %@", responseObject);
        
        NSDictionary *infos = [responseObject objectForKey:@"retData"];
        if (infos) {
            ///气温
            if ([infos objectForKey:@"l_tmp"]) {
                [weatherInfo setObject:[NSString stringWithFormat:@"%@~%@",[infos objectForKey:@"l_tmp"],[infos objectForKey:@"h_tmp"]] forKey:@"temperature"];
            }
            ///天气
            if ([infos objectForKey:@"weather"]) {
                [weatherInfo setObject:[infos objectForKey:@"weather"] forKey:@"weather"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"weather_infos" object:weatherInfo];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"getWeatherInfosByCityName Error: %@", error);
    }];
}


/*
///根据城市名称获取其天气信息
+(void)getWeatherInfosByCityName:(NSString *)cityName{
    NSMutableDictionary *weatherInfo = [[NSMutableDictionary alloc] init];
    NSString *code = [self getCityCodeByName:cityName];
    NSString *url = [NSString stringWithFormat:@"%@%@.html",URL_WEATHER,code];
    NSLog(@"url:%@",url);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置请求参数的格式：JSON格式
    manager.requestSerializer =  [AFJSONRequestSerializer serializer];
    // 设置返回数据的解析方式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"天气信息: %@", responseObject);
        
        NSDictionary *infos = [responseObject objectForKey:@"weatherinfo"];
        if (infos) {
            ///气温
            if ([infos objectForKey:@"temp1"]) {
                [weatherInfo setObject:[infos objectForKey:@"temp1"] forKey:@"temperature"];
            }
            ///天气
            if ([infos objectForKey:@"weather1"]) {
                [weatherInfo setObject:[infos objectForKey:@"weather1"] forKey:@"weather"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"weather_infos" object:weatherInfo];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        NSLog(@"Error: %@", error);
    }];
}
 */

@end
