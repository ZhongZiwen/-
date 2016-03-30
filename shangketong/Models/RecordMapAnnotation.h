//
//  RecordMapAnnotation.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RecordMapAnnotation : NSObject<MKAnnotation>

@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;

- (instancetype)initWithTitle:(NSString*)atitle latitue:(float)alatitue longitude:(float)alongitude;
- (instancetype)initWithTitle:(NSString*)atitle coordinate:(CLLocationCoordinate2D)location;
@end
