//
//  ReportViewCell.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-18.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "ReportViewCell.h"
#import "ChartView.h"
#import "LLCenterUtility.h"

@interface ReportViewCell () {
    ChartView *chartViewLength,*chartViewTimes;
}

@end

@implementation ReportViewCell

- (void)setCellDataInfo:(CellDataInfo*)cInfo {
    
    
    if (!cInfo.cellDataInfo) {
        return;
    }
    float timePercentage = [self getPercentageFromString:[cInfo.cellDataInfo safeObjectForKey:@"CALL_TIME_SCALE"]];
    float countPercentage = [self getPercentageFromString:[cInfo.cellDataInfo safeObjectForKey:@"CALL_COUNT_SCALE"]];
    NSString *timeString = [NSString stringWithFormat:@"%@(%@分钟)",[cInfo.cellDataInfo safeObjectForKey:@"CALL_TIME_SCALE"],[cInfo.cellDataInfo safeObjectForKey:@"CALL_TIME"]];
    NSString *countString = [NSString stringWithFormat:@"%@(%@次)",[cInfo.cellDataInfo safeObjectForKey:@"CALL_COUNT_SCALE"],[cInfo.cellDataInfo safeObjectForKey:@"CALL_COUNT"]];
    
//    id tileName = [self getNameString:cInfo.cellDataInfo];
//    if (tileName == nil || tileName == [NSNull null] || [tileName isEqualToString:@"<null>"]) {
//        labelName.text = @"";
//    }else{
//        labelName.text = [self getNameString:cInfo.cellDataInfo];
//    }
    labelName.text = [self getNameString:cInfo.cellDataInfo];
    
    /*
    //For time
    chartViewLength = [[ChartView alloc] initWithFrame:CGRectMake(80, 12, 240, 15) chartPercentage:timePercentage chartColor:GetColorWithRGB(0, 169, 251) labelString:timeString labelOccupy:0.4];
     */
    
    //For count
    chartViewTimes = [[ChartView alloc] initWithFrame:CGRectMake(80, 17, 240, 15) chartPercentage:countPercentage chartColor:GetColorWithRGB(255, 178, 68) labelString:countString labelOccupy:0.4];
    
//    [self.contentView addSubview:chartViewLength];
    [self.contentView addSubview:chartViewTimes];
}

- (float)getPercentageFromString:(NSString*)str {
    if (!str) {
        return 0;
    }
    str = [str stringByReplacingOccurrencesOfString:@"%" withString:@""];
    return [str floatValue] / 100.0;
}

- (NSString*)getNameString:(NSDictionary*)_dict {
    NSEnumerator *enm = [_dict keyEnumerator];
    for (NSString *key in enm) {
        if ([key isEqualToString:@"CALL_TIME_SCALE"] || [key isEqualToString:@"CALL_COUNT_SCALE"] || [key isEqualToString:@"CALL_TIME"] || [key isEqualToString:@"CALL_COUNT"]) {
            continue;
        }
         return  [_dict safeObjectForKey:key];
//        return [_dict objectForKey:key];
    }
    return nil;
}

// UI 适配
-(void)setCellViewFrame
{
    view_line.frame = CGRectMake(0, 49, DEVICE_BOUNDS_WIDTH, 1);
    
    /*
    if (DEVICE_IS_IPHONE6) {
        view_line.frame = CGRectMake(0, 59, DEVICE_BOUNDS_WIDTH, 1);
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
        
    }else if(!DEVICE_IS_IPHONE5)
    {
        
        
    }else
    {
        
    }
     */
}

@end
