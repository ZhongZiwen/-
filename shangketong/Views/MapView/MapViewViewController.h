//
//  MapViewViewController.h
//  DemoMapViewPOI
//
//  Created by sungoin-zjp on 15-5-8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
@interface MapViewViewController : UIViewController

@property(strong,nonatomic) MKMapView *mapview;
@property(strong,nonatomic) CLLocationManager *locationManager;


///需要展示的经纬度、地址信息
@property(assign,nonatomic)double latitude;
@property(assign,nonatomic)double longitude;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *locationDetail;


///POI
@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) MKLocalSearchRequest *localSearchRequest;

///显示 or  定位
@property (nonatomic, strong) NSString *typeOfMap;


@property (nonatomic, copy) void (^LocationResultBlock)(CLLocationCoordinate2D locCoordinate,NSString *location);

@end
