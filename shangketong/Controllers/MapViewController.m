//
//  MapViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "SKTLocationManager.h"
#import "MapLocation.h"

@interface MapViewController ()<MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@end

@implementation MapViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 停止定位
    SKTLocationManager *appLocationNanager = [SKTLocationManager sharedLocationManager];
    [appLocationNanager.locationManager stopUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //    __weak __block typeof(self) weak_self = self;
    //    SKTLocationManager *appLocationManager = [SKTLocationManager sharedLocationManager];
    //    [appLocationManager getLocationWithCompletionBlock:^(CLLocation *location, NSError *error) {
    //        if (error) {
    //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //            [alertView show];
    //        }
    //
    ////        [self zoomMapToFitAnnotations];
    //
    //        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
    //            if ([placemarks count] > 0) {
    //                [weak_self.mapView removeAnnotations:weak_self.mapView.annotations];
    //                [weak_self.mapView removeOverlays:weak_self.mapView.overlays];
    //            }
    //
    //            for (int i = 0; i < placemarks.count; i ++) {
    //                CLPlacemark *placemark = placemarks[i];
    //
    //                // 调整地图位置和缩放比例
    //                MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, 1000, 1000);
    //                [weak_self.mapView setRegion:viewRegion animated:YES];
    //
    //                MapLocation *annotation = [[MapLocation alloc] init];
    //                annotation.streetAddress = placemark.thoroughfare;
    //                annotation.city = placemark.locality;
    //                annotation.state = placemark.administrativeArea;
    //                annotation.coordinate = placemark.location.coordinate;
    //
    //                [weak_self.mapView addAnnotation:annotation];
    //                [weak_self.mapView selectAnnotation:annotation animated:YES];
    //            }
    //        }];
    //
    //    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // 检查定位服务是否已开启
    if ([CLLocationManager locationServicesEnabled]) {
        SKTLocationManager *appLocationManager = [SKTLocationManager sharedLocationManager];
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0) {
            // 设置定位权限 仅iOS8有意义
            if([appLocationManager.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//                [appLocationManager.locationManager requestAlwaysAuthorization]; // 永久授权
                [appLocationManager.locationManager requestWhenInUseAuthorization]; //使用中授权
            }
        }
        [appLocationManager.locationManager startUpdatingLocation];
    }else {
        NSLog(@"定位服务不能用");
    }
    
    [self.view addSubview:self.mapView];
    
    [self updateMapAnnotations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)zoomMapToFitAnnotations {
    CLLocationCoordinate2D maxCoordinate = CLLocationCoordinate2DMake(-90.0, -180.0);
    
    CLLocationCoordinate2D minCoordinate = CLLocationCoordinate2DMake(90.0, 180.0);
    
    NSMutableArray *currentPlaces = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    [currentPlaces removeObject:self.mapView.userLocation];
    
    maxCoordinate.latitude = [[currentPlaces valueForKeyPath:@"@max.latitude"] doubleValue];
    
    minCoordinate.latitude = [[currentPlaces valueForKeyPath:@"@min.latitude"] doubleValue];
    
    maxCoordinate.longitude = [[currentPlaces valueForKeyPath:@"@max.longitude"] doubleValue];
    
    minCoordinate.longitude = [[currentPlaces valueForKeyPath:@"@min.longitude"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate;
    
    centerCoordinate.longitude = (minCoordinate.longitude + maxCoordinate.longitude) / 2.0;
    
    centerCoordinate.latitude = (minCoordinate.latitude + maxCoordinate.latitude) / 2.0;
    
    MKCoordinateSpan span;
    
    span.longitudeDelta = (maxCoordinate.longitude - minCoordinate.longitude) * 1.2;
    
    span.latitudeDelta = (maxCoordinate.latitude - minCoordinate.latitude) * 1.2;
    
    MKCoordinateRegion newRegion = MKCoordinateRegionMake(centerCoordinate, span);
    
    [self.mapView setRegion:newRegion animated:YES];
}

- (void)updateMapAnnotations {
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeOverlays:_mapView.overlays];
}

#pragma mark - event response
- (void)leftButtonPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonPress {
    
}

#pragma mark - MKMapViewDelegate
// 平移或缩放地图调用
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    MKCoordinateRegion newRegion = [mapView region];
    CLLocationCoordinate2D center = newRegion.center;
    MKCoordinateSpan span = newRegion.span;
}

// - (void)addAnnotation:(id <MKAnnotation>)annotation;被调用的时候，该委托方法就会被回调
- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    //    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:@"PIN_ANNOTATION"];
    //    if (annotationView == nil) {
    //        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PIN_ANNOTATION"];
    //    }
    //
    //    annotationView.canShowCallout = YES;
    //
    //    return annotationView;
    return nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    _mapView.centerCoordinate = userLocation.location.coordinate;
    
    // 调整地图位置和缩放比例
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 300, 300);
    [_mapView setRegion:viewRegion animated:YES];
    
    //    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
    //        for (int i = 0; i < placemarks.count; i ++) {
    //            CLPlacemark *placemark = placemarks[i];
    //
    //            MapLocation *annotation = [[MapLocation alloc] init];
    //            annotation.streetAddress = placemark.thoroughfare;
    //            annotation.city = placemark.locality;
    //            annotation.state = placemark.administrativeArea;
    //            annotation.coordinate = placemark.location.coordinate;
    //
    //            NSLog(@"地址信息 = %@ %@ %@", annotation.streetAddress, annotation.city, annotation.state);
    //        }
    //
    //    }];
}

#pragma mark - setters and getters
- (MKMapView*)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.mapType = MKMapTypeStandard;
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
        [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
    return _mapView;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
