//
// Created by Jörg Polakowski on 14/12/13.
// Copyright (c) 2013 kevinzhow. All rights reserved.
//

#import "PNLineChartData.h"
#import "CommonStaticVar.h"

@implementation PNLineChartData

- (id)init
{
    self = [super init];
    if (self) {
        [self setupDefaultValues];
    }
    
    return self;
}

- (void)setupDefaultValues
{
    _inflexionPointStyle = PNLineChartPointStyleNone;
    ///联络中心 取消相关动画
    if ([[CommonStaticVar getFromLLCenterView] isEqualToString:@"llcenter"]) {
        _inflexionPointWidth = 10.f;
    }else{
        _inflexionPointWidth = 6.f;
    }
    
    _lineWidth = 2.f;
    _alpha = 1.f;
}

@end
