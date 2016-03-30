//
//  MapLocation.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapLocation : NSObject<MKAnnotation>

// 地图坐标
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
// 街道信息属性
@property (nonatomic, copy) NSString *streetAddress;
// 城市信息熟悉
@property (nonatomic, copy) NSString *city;
// 州、省、市信息
@property (nonatomic, copy) NSString *state;

@end
