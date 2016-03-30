//
//  ActivityRecordLocaitonMapController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordLocaitonMapController.h"
#import <MapKit/MapKit.h>
#import "Record.h"
#import "LocationHelper.h"
#import "RecordMapAnnotation.h"

@interface ActivityRecordLocaitonMapController ()<MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@end

@implementation ActivityRecordLocaitonMapController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    [self.view addSubview:self.mapView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    @try {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [_record.latitude doubleValue];
        coordinate.longitude = [_record.longitude doubleValue];
        
        coordinate = [LocationHelper bdToGGEncrypt:coordinate];
        
        RecordMapAnnotation *newAnnotation = [[RecordMapAnnotation alloc] initWithTitle:_record.position coordinate:coordinate];
        newAnnotation.subtitle = _record.position;
        [self.mapView addAnnotation:newAnnotation];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 250, 250);
        [self.mapView setRegion:region animated:YES];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
//    if ([annotation isKindOfClass:[RecordMapAnnotation class]]) {
//        
//        static NSString *userLocationStyleReuseIndetifier = @"CustomAnnotation";
//        
//        MKAnnotationView *annotationView =[self.mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
//        if (!annotationView) {
//            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
//                                                          reuseIdentifier:userLocationStyleReuseIndetifier];
//            annotationView.canShowCallout = YES;
//            annotationView.image = [UIImage imageNamed:@"UMS_follow_on"];
//        }
//        return annotationView;
//    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *annotationView = [views objectAtIndex:0];
    id <MKAnnotation> mp = [annotationView annotation];
    
    [self.mapView selectAnnotation:mp animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (MKMapView*)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        _mapView.mapType = MKMapTypeStandard;
        //显示用户位置（蓝色发光圆圈），还有None和FollowWithHeading两种，当有这个属性的时候，iOS8第一次打开地图，会自动定位并显示这个位置。iOS7模拟器上不会。
//        _mapView.userTrackingMode = MKUserTrackingModeNone;
        [_mapView setZoomEnabled:YES];
        [_mapView setScrollEnabled:YES];
    }
    return _mapView;
}
@end
