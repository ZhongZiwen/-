//
//  MapViewViewController.m
//  DemoMapViewPOI
//
//  Created by sungoin-zjp on 15-5-8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MapViewViewController.h"
#import "AppDelegate.h"
#import "CommonConstant.h"
#import "LocationAnnotation.h"
#import "LocationChange.h"
#import "POITableViewController.h"
#import <MBProgressHUD.h>


@interface MapViewViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,SelectPOIDelegate,UIGestureRecognizerDelegate>
{
    CLLocationCoordinate2D       locCoordinate;
    NSMutableArray *arrayPOI;
    NSString *curLocationName;
    NSString *curLocationStreet;
    
    ///定位type  gd/apple
    NSString *mapviewType;
    
    ///切换按钮
    UIButton *btnChangeLocationType;
    ///地图选择弹框
    UIView *menuViewBg;
    UIView *menuView;
    
    ///清除mapview标记
    BOOL isRemoveMap;
}

@end

@implementation MapViewViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    ///默认高德
    mapviewType = @"gd";
    self.mapview = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.mapview.delegate = self;
    self.mapview.mapType = MKMapTypeStandard;
    //    self.mapview.showsUserLocation = YES;
    self.mapview.zoomEnabled = YES;
    [self.view addSubview:self.mapview];

    ///显示位置信息
    if ([self.typeOfMap isEqualToString:@"show"]) {
        self.title = @"查看地理位置";
        [self showLocationByCoordinate];
        
    }else{
        self.title = @"地图";
        arrayPOI = [[NSMutableArray alloc] init];
        [self addLocationBtn];
        [self getCurPosition];
    }
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        kShowHUD(@"请打开您的位置服务!");
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isRemoveMap = TRUE;
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (isRemoveMap) {
        self.mapview.showsUserLocation = NO;
        self.mapview.delegate = nil;
        [self.mapview removeFromSuperview];
        self.mapview = nil;
        self.locationManager = nil;
        self.localSearch = nil;
        self.localSearchRequest = nil;
    }
}


#pragma mark - 弹框view
////添加菜单
-(void)addMenuView{
    
    NSInteger widthMenu = kScreen_Width-30;
    NSInteger heightMenu = 170;
    
    ///bg
    menuViewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    [menuViewBg setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.300]];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [menuViewBg addGestureRecognizer:singleTap];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    [appDelegateAccessor.window addSubview:menuViewBg];
    
    
    ///menuview
    menuView = [[UIView alloc] initWithFrame:CGRectMake(15, (kScreen_Height-heightMenu)/2, widthMenu, heightMenu)];
    menuView.layer.cornerRadius = 12;
    menuView.layer.masksToBounds = YES;
    menuView.backgroundColor = [UIColor whiteColor];
    [menuViewBg addSubview:menuView];
    
    
    ///menu item
    NSInteger btnSize = 50;
    UIButton *btnGDMap = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGDMap.frame = CGRectMake(40, 30, btnSize, btnSize);
    [btnGDMap setBackgroundImage:[UIImage imageNamed:@"icon_gaode_large.png"] forState:UIControlStateNormal];
    [btnGDMap addTarget:self action:@selector(selectLocationType:) forControlEvents:UIControlEventTouchUpInside];
    btnGDMap.tag = 101;
    
    UILabel *labelGD = [[UILabel alloc] initWithFrame:CGRectMake(40, btnGDMap.frame.origin.y+btnSize+7, btnSize, 40)];
    labelGD.font = [UIFont systemFontOfSize:12.0];
    labelGD.textAlignment = NSTextAlignmentCenter;
    labelGD.numberOfLines = 0;
    labelGD.text = @"高德地图\n(中国)";
    
    [menuView addSubview:btnGDMap];
    [menuView addSubview:labelGD];
    
    UIButton *btnAppleMap = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAppleMap.frame = CGRectMake(menuView.frame.size.width-40-btnSize, 30, btnSize, btnSize);
    [btnAppleMap setBackgroundImage:[UIImage imageNamed:@"icon_apple_large.png"] forState:UIControlStateNormal];
    [btnAppleMap addTarget:self action:@selector(selectLocationType:) forControlEvents:UIControlEventTouchUpInside];
    btnAppleMap.tag = 102;
    
    UILabel *labelApple = [[UILabel alloc] initWithFrame:CGRectMake(btnAppleMap.frame.origin.x, btnAppleMap.frame.origin.y+btnSize+7, btnSize, 40)];
    labelApple.font = [UIFont systemFontOfSize:12.0];
    labelApple.textAlignment = NSTextAlignmentCenter;
    labelApple.numberOfLines = 0;
    labelApple.text = @"苹果地图\n(全球)";
    
    [menuView addSubview:btnAppleMap];
    [menuView addSubview:labelApple];
    
    ///分隔线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, labelApple.frame.origin.y+labelApple.frame.size.height+7, widthMenu-40, 1)];
    lineView.backgroundColor = [UIColor grayColor];
    [menuView addSubview:lineView];
    
    
    ///提示信息
    UILabel *labelNotice = [[UILabel alloc] initWithFrame:CGRectMake(0, lineView.frame.origin.y+9, widthMenu, 20)];
    [labelNotice setTextColor:[UIColor grayColor]];
    labelNotice.font = [UIFont systemFontOfSize:12.0];
    labelNotice.textAlignment = NSTextAlignmentCenter;
    labelNotice.text = @"当无法定位或定位不准,请尝试切换地图";
    
    [menuView addSubview:labelNotice];
    
    if ([mapviewType isEqualToString:@"gd"]) {
        
        [btnGDMap setBackgroundImage:[UIImage imageNamed:@"icon_gaode_large.png"] forState:UIControlStateNormal];
        [btnAppleMap setBackgroundImage:[UIImage imageNamed:@"icon_apple_large.png"] forState:UIControlStateNormal];
    }else if ([mapviewType isEqualToString:@"apple"]) {
        
        [btnGDMap setBackgroundImage:[UIImage imageNamed:@"icon_gaode_large.png"] forState:UIControlStateNormal];
        [btnAppleMap setBackgroundImage:[UIImage imageNamed:@"icon_apple_large.png"] forState:UIControlStateNormal];
    }
}



////点击背景事件
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.view];
    NSLog(@"handleSingleTap!pointx:%f,y:%f",point.x,point.y);
    
    if (point.y > menuView.frame.origin.y && point.y < menuView.frame.origin.y+menuView.frame.size.height) {
        return;
    }
    
    if(menuViewBg != nil)
    {
        [menuViewBg removeFromSuperview];
        menuViewBg = nil;
    }
}


////menu按钮事件
-(void)selectLocationType:(id)sender{
    UIButton *btn = (UIButton*)sender;
    NSInteger tag = btn.tag;
    
    if(menuViewBg != nil)
    {
        [menuViewBg removeFromSuperview];
        menuViewBg = nil;
    }
    
    if (tag == 101) {
        ///高德地图
        [btnChangeLocationType setBackgroundImage:[UIImage imageNamed:@"icon_gaode_large.png"] forState:UIControlStateNormal];
        mapviewType = @"gd";
        self.typeOfMap = @"location";
        [self.mapview removeAnnotations:self.mapview.annotations];
        self.mapview.showsUserLocation = YES;
    }else if(tag == 102){
        ///苹果地图
        [btnChangeLocationType setBackgroundImage:[UIImage imageNamed:@"icon_apple_large.png"] forState:UIControlStateNormal];
        mapviewType = @"apple";
        self.typeOfMap = @"show";
        [self.mapview removeAnnotations:self.mapview.annotations];
        [self.locationManager startUpdatingLocation];
    }
}


#pragma mark - 确定按钮事件
// 完成按钮
-(void)addNarOKBtn{
    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(okBtnPressed)];
    self.navigationItem.rightBarButtonItem = okButton;
}


-(void)okBtnPressed{
    NSLog(@"latitude:%f",locCoordinate.latitude);
    NSLog(@"longitude:%f",locCoordinate.longitude);
    NSLog(@"curLocationName:%@",curLocationName);
    NSLog(@"curLocationStreet:%@",curLocationStreet);
    
    [self.navigationController popViewControllerAnimated:YES];

    if (self.LocationResultBlock) {
        self.LocationResultBlock(locCoordinate,curLocationStreet);
    }
    
    
}

#pragma mark - 定位按钮
-(void)addLocationBtn{
    
    ///右上角切换
    UIView *viewChange = [[UIView alloc] initWithFrame:CGRectMake(kScreen_Width-50, 110, 45, 45)];
    viewChange.layer.cornerRadius = 5;
    viewChange.backgroundColor = [UIColor whiteColor];
    
    ///切换按钮
    btnChangeLocationType = [UIButton buttonWithType:UIButtonTypeCustom];
    btnChangeLocationType.frame = CGRectMake(10, 5, 25, 25);
    [btnChangeLocationType setBackgroundImage:[UIImage imageNamed:@"icon_gaode_large.png"] forState:UIControlStateNormal];
    [btnChangeLocationType addTarget:self action:@selector(changeMapview) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *labelChange = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 45, 15)];
    labelChange.textAlignment = NSTextAlignmentCenter;
    labelChange.font = [UIFont systemFontOfSize:10.0];
    labelChange.text = @"切换";
    
    [viewChange addSubview:btnChangeLocationType];
    [viewChange addSubview:labelChange];
    
    [self.view addSubview:viewChange];
    
    
    ///左下角定位
    UIView *viewLocation = [[UIView alloc] initWithFrame:CGRectMake(10, kScreen_Height-100, 45, 45)];
    viewLocation.layer.cornerRadius = 5;
    viewLocation.backgroundColor = [UIColor whiteColor];
    ///定位按钮
    UIButton *btnLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLocation.frame = CGRectMake(10, 5, 25, 25);
    [btnLocation setBackgroundImage:[UIImage imageNamed:@"more_lead_gray.png"] forState:UIControlStateNormal];
    [btnLocation addTarget:self action:@selector(startLocation) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *labelLocation = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 45, 15)];
    labelLocation.textAlignment = NSTextAlignmentCenter;
    labelLocation.font = [UIFont systemFontOfSize:10.0];
    labelLocation.text = @"定位";
    
    [viewLocation addSubview:btnLocation];
    [viewLocation addSubview:labelLocation];
    
    
    [self.view addSubview:viewLocation];
}


////重新定位
-(void)startLocation{
    NSLog(@"startLocation--->");
    self.navigationItem.rightBarButtonItem = nil;
    [self.mapview removeAnnotations:self.mapview.annotations];
    
    if ([mapviewType isEqualToString:@"gd"]) {
        ///高德地图
        self.typeOfMap = @"location";
        [self.mapview removeAnnotations:self.mapview.annotations];
        self.mapview.showsUserLocation = YES;
    }else if([mapviewType isEqualToString:@"apple"]){
        ///苹果地图
        self.typeOfMap = @"show";
        [self.mapview removeAnnotations:self.mapview.annotations];
        [self.locationManager startUpdatingLocation];
    }
}

///切换定位方式
-(void)changeMapview{
    self.navigationItem.rightBarButtonItem = nil;
    ///---MKMapView 与 CLLocationManager 做定位切换
    [self addMenuView];
}

#pragma mark - 根据经纬度显示位置
-(void)showLocationByCoordinate{
    NSLog(@"self.latitude:%f",self.latitude);
    NSLog(@"self.longitude:%f",self.longitude);
    locCoordinate.latitude = self.latitude;
    locCoordinate.longitude = self.longitude;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locCoordinate,500, 500);//以pos为中心，显示1000米
    MKCoordinateRegion adjustedRegion = [self.mapview regionThatFits:viewRegion];//适配map view的尺寸
    [self.mapview setRegion:adjustedRegion animated:YES];
    
    if (self.location == nil) {
        self.location = @"";
    }
    
    if (self.locationDetail == nil) {
        self.locationDetail = @"";
    }
    
    LocationAnnotation * annotation = [[LocationAnnotation alloc] initWithCoordinates:locCoordinate title:self.location subTitle:self.locationDetail];
    
    [self.mapview addAnnotation:annotation];
    //自动显示标注的layout
    [self.mapview selectAnnotation:annotation animated:YES];
    
    /*
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    [geo reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        
        
        for (CLPlacemark * placemark in placemarks)
        {
            NSString *curAddress = @"";
            if([placemark.addressDictionary objectForKey:@"FormattedAddressLines"] != NULL)
            {
                curAddress = [[placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            }
            else{
                curAddress = @"";
            }
            
            
            NSString *fullThoroughfare = @"";
            if([placemark.addressDictionary objectForKey:@"Thoroughfare"] != NULL)
            {
                fullThoroughfare = [placemark.addressDictionary objectForKey:@"Thoroughfare"];
            }
            else{
                fullThoroughfare = @"";
            }
            NSLog(@"placemark:%@", placemark );
            NSLog(@"地址:%@", curAddress);
            NSLog(@"fullThoroughfare:%@", fullThoroughfare);
            
            
            NSLog(@"%@ ",[placemark.addressDictionary objectForKey:@"City"]);
            NSLog(@"%@",[placemark.addressDictionary objectForKey:@"Country"]);
            NSLog(@"%@",[placemark.addressDictionary objectForKey:@"CountryCode"]);
            NSLog(@"%@",[placemark.addressDictionary objectForKey:@"State"]);
            NSLog(@"%@",[placemark.addressDictionary objectForKey:@"Street"]);
            NSLog(@"%@",[placemark.addressDictionary objectForKey:@"SubLocality"]);
            NSLog(@"%@",[placemark.addressDictionary objectForKey:@"Thoroughfare"]);
            NSLog(@"Street:%@",[placemark.addressDictionary objectForKey:@"Locality"]);
            
            //                NSLog(@"placemark:%@",placemark);
            
            
            curLocationName = [placemark.addressDictionary objectForKey:@"Street"];
            curLocationStreet = curAddress;
            LocationAnnotation * annotation = [[LocationAnnotation alloc] initWithCoordinates:locCoordinate title:curLocationName subTitle:curLocationStreet];
            
            [self.mapview addAnnotation:annotation];
            //自动显示标注的layout
            [self.mapview selectAnnotation:annotation animated:YES];
        }
        
    }];
     */
}

#pragma mark - 刷新当前mapview
-(void)notifyMapViewBySelectedPOI:(MKMapItem *)mapItem{
    //    self.mapview removeAnnotation:<#(id<MKAnnotation>)#>
    NSLog(@"notifyMapViewBySelectedPOI vmapItem:%@",mapItem);
    [self.mapview removeAnnotations:self.mapview.annotations];
    
    locCoordinate = mapItem.placemark.coordinate;
    NSLog(@"latitude:%f",mapItem.placemark.coordinate.latitude);
    NSLog(@"longitude:%f",mapItem.placemark.coordinate.longitude);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locCoordinate,500, 500);//以pos为中心，显示1000米
    MKCoordinateRegion adjustedRegion = [self.mapview regionThatFits:viewRegion];//适配map view的尺寸
    [self.mapview setRegion:adjustedRegion animated:YES];
    
    curLocationName = mapItem.name;;
    curLocationStreet = [mapItem.placemark.addressDictionary objectForKey:@"Street"];
    LocationAnnotation * annotation = [[LocationAnnotation alloc] initWithCoordinates:locCoordinate title:curLocationName subTitle:curLocationStreet];
    
    [self.mapview addAnnotation:annotation];
    //自动显示标注的layout
    [self.mapview selectAnnotation:annotation animated:YES];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self issueLocalSearchLookup:SEARCH_KEY_WORDS usingPlacemarksArray:locCoordinate];
    });
}


#pragma mark - 定位
- (void) getCurPosition
{
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    if ([CLLocationManager locationServicesEnabled])
    {
        // 判断是否iOS 8
        if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            NSLog(@"ios 8.0--->");
            [self.locationManager requestAlwaysAuthorization]; // 使用中授权
            //            [self.locationManager requestWhenInUseAuthorization]; //使用中授权
        }
        self.locationManager.delegate=self;
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        self.locationManager.distanceFilter=10.0f;
        NSLog(@"startUpdatingLocation--->");
        
        //        [self.locationManager startUpdatingLocation];
        self.mapview.showsUserLocation = YES;
    }else{
        NSLog(@"请开启定位权限");
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"didChangeAuthorizationStatus----->");
}

#pragma mark - CLLocationManager获取定位
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"locationManager  didUpdateLocations---->");
    //GPS坐标  WGS84坐标系
    if ([locations count] > 0) {
        ///显示位置信息
        if (![self.typeOfMap isEqualToString:@"show"]) {
            [self addNarOKBtn];
        }
        
        [self.locationManager stopUpdatingLocation];
        CLLocation* loc = [locations lastObject];
        locCoordinate = [loc coordinate];
        //        NSLog(@"old loc:%@",loc);
        //        NSLog(@"locationManager, longitude: %f, latitude: %f", locCoordinate.longitude, locCoordinate.latitude);
        
        ///对坐标做转换
        [self transform_earth_from_mars];
        NSLog(@"locationManager  locationManager, longitude: %f, latitude: %f", locCoordinate.longitude, locCoordinate.latitude);
        CLLocation* newloc = [[CLLocation alloc] initWithLatitude:locCoordinate.latitude longitude:locCoordinate.longitude];
        
        //        NSLog(@"locationManager, longitude: %f, latitude: %f", locCoordinate.longitude, locCoordinate.latitude);
        //        NSLog(@"new loc:%@",newloc);
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locCoordinate,500, 500);//以pos为中心，显示1000米
        MKCoordinateRegion adjustedRegion = [self.mapview regionThatFits:viewRegion];//适配map view的尺寸
        [self.mapview setRegion:adjustedRegion animated:YES];
        
        
        CLGeocoder *geo = [[CLGeocoder alloc] init];
        [geo reverseGeocodeLocation:newloc completionHandler:^(NSArray *placemarks, NSError *error) {
            
            
            for (CLPlacemark * placemark in placemarks)
            {
                NSString *curAddress = @"";
                if([placemark.addressDictionary objectForKey:@"FormattedAddressLines"] != NULL)
                {
                    curAddress = [[placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                }
                else{
                    curAddress = @"";
                }
                NSLog(@"地址:%@", curAddress);
                //                NSLog(@"addressDictionary:%@", placemark.addressDictionary);
                
                NSLog(@"%@ ",[placemark.addressDictionary objectForKey:@"City"]);
                NSLog(@"%@",[placemark.addressDictionary objectForKey:@"Country"]);
                NSLog(@"%@",[placemark.addressDictionary objectForKey:@"CountryCode"]);
                NSLog(@"%@",[placemark.addressDictionary objectForKey:@"State"]);
                NSLog(@"%@",[placemark.addressDictionary objectForKey:@"Street"]);
                NSLog(@"%@",[placemark.addressDictionary objectForKey:@"SubLocality"]);
                NSLog(@"%@",[placemark.addressDictionary objectForKey:@"Thoroughfare"]);
                
                
                // NSLog(@"placemark:%@",placemark);
                
                
                curLocationName = [placemark.addressDictionary objectForKey:@"Street"];
                curLocationStreet = curAddress;
                LocationAnnotation * annotation = [[LocationAnnotation alloc] initWithCoordinates:locCoordinate title:curLocationName subTitle:curLocationStreet];
                
                [self.mapview addAnnotation:annotation];
                //自动显示标注的layout
                [self.mapview selectAnnotation:annotation animated:YES]; 
            }
            
        }];
        
    }
}


-(void)addAnnotationAndSearchPOI:(CLLocationCoordinate2D)pos{
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    isRemoveMap = FALSE;
    
    POITableViewController  *controller = [[POITableViewController alloc] init];
    controller.delegate = self;
    controller.poiArray = arrayPOI;
    controller.curLocationName = curLocationName;
    controller.curLocationStreet = curLocationStreet;
    [self.navigationController pushViewController:controller animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([self.typeOfMap isEqualToString:@"show"]) {
        return nil;
    }else{
        MKAnnotationView *returnedAnnotationView = nil;
        if (![annotation isKindOfClass:[MKUserLocation class]])
        {
            if ([annotation isKindOfClass:[LocationAnnotation class]])
            {
                returnedAnnotationView = [LocationAnnotation createViewAnnotationForMapView:self.mapview annotation:annotation];
                
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
                ((MKPinAnnotationView *)returnedAnnotationView).rightCalloutAccessoryView = rightButton;
            }
        }
        return returnedAnnotationView;
    }
}

-(void)issueLocalSearchLookup:(NSString *)searchString usingPlacemarksArray:(CLLocationCoordinate2D)coords {
    NSLog(@"issueLocalSearchLookup--->");
    MKCoordinateSpan span = MKCoordinateSpanMake(0.6250, 0.6250);
    MKCoordinateRegion region = MKCoordinateRegionMake(coords, span);
    
    // Create the search request
    self.localSearchRequest = [[MKLocalSearchRequest alloc] init];
    self.localSearchRequest.region = region;
    self.localSearchRequest.naturalLanguageQuery = searchString;
    
    // Perform the search request...
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:self.localSearchRequest];
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        if(error){
            
            NSLog(@"localSearch startWithCompletionHandlerFailed!  Error: %@", error);
            return;
        } else {
            
            if (arrayPOI == nil) {
                arrayPOI = [[NSMutableArray alloc] init];
            }else{
                [arrayPOI removeAllObjects];
            }
            [arrayPOI addObjectsFromArray:response.mapItems];
            
            //            NSLog(@"arrayPOI:%@",arrayPOI);
        }
    }];
}

///地图坐标转换为火星坐标
-(void)transform_earth_from_mars{
    //
    double marsLat,marsLon;
    transform_earth_from_mars(locCoordinate.latitude, locCoordinate.longitude, &marsLat, &marsLon);
    
    locCoordinate.latitude = marsLat;
    locCoordinate.longitude = marsLon;
}

#pragma mark - mapView获取定位
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    NSLog(@"mapView  didUpdateUserLocation---->");
    self.mapview.showsUserLocation = NO;
    
    if (![self.typeOfMap isEqualToString:@"show"]) {
        [self addNarOKBtn];
    }
    
    locCoordinate = [userLocation coordinate];
    //火星坐标
    NSLog(@"mapView  locationManager, longitude: %f, latitude: %f", locCoordinate.longitude, locCoordinate.latitude);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locCoordinate,500, 500);//以pos为中心，显示1000米
    MKCoordinateRegion adjustedRegion = [self.mapview regionThatFits:viewRegion];//适配map view的尺寸
    [self.mapview setRegion:adjustedRegion animated:YES];
    
    CLLocation* newloc = [[CLLocation alloc] initWithLatitude:locCoordinate.latitude longitude:locCoordinate.longitude];
    
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    [geo reverseGeocodeLocation:newloc completionHandler:^(NSArray *placemarks, NSError *error) {
        
        for (CLPlacemark * placemark in placemarks)
        {
            NSString *curAddress = @"";
            if([placemark.addressDictionary objectForKey:@"FormattedAddressLines"] != NULL)
            {
                curAddress = [[placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            }
            else{
                curAddress = @"";
            }
            NSLog(@"地址:%@", curAddress);
            //            NSLog(@"addressDictionary:%@", placemark.addressDictionary);
            
            NSLog(@"%@ ",[placemark.addressDictionary objectForKey:@"City"]);
            NSLog(@"%@",[placemark.addressDictionary objectForKey:@"Country"]);
            NSLog(@"%@",[placemark.addressDictionary objectForKey:@"CountryCode"]);
            NSLog(@"%@",[placemark.addressDictionary objectForKey:@"State"]);
            NSLog(@"%@",[placemark.addressDictionary objectForKey:@"Street"]);
            NSLog(@"%@",[placemark.addressDictionary objectForKey:@"SubLocality"]);
            NSLog(@"%@",[placemark.addressDictionary objectForKey:@"Thoroughfare"]);
            
            //                NSLog(@"placemark:%@",placemark);
            
            curLocationName = [placemark.addressDictionary objectForKey:@"Street"];
            curLocationStreet = curAddress;
            LocationAnnotation * annotation = [[LocationAnnotation alloc] initWithCoordinates:locCoordinate title:curLocationName subTitle:curLocationStreet];
            
            [self.mapview addAnnotation:annotation];
            //自动显示标注的layout
            [self.mapview selectAnnotation:annotation animated:YES];
        }
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self issueLocalSearchLookup:SEARCH_KEY_WORDS usingPlacemarksArray:locCoordinate];
    });
}

/*
 
 {
 City = "\U4e0a\U6d77\U5e02\U5e02\U8f96\U533a";
 Country = "\U4e2d\U534e\U4eba\U6c11\U5171\U548c\U56fd";
 CountryCode = CN;
 FormattedAddressLines =     (
 "\U4e2d\U534e\U4eba\U6c11\U5171\U548c\U56fd\U4e0a\U6d77\U5e02\U95f5\U884c\U533a\U5434\U4e2d\U8def699"
 );
 Name = "\U5927\U4f17\U7f8e\U6797\U9601\U5927\U9152\U5e97";
 State = "\U4e0a\U6d77\U5e02";
 Street = "\U5434\U4e2d\U8def699";
 SubLocality = "\U95f5\U884c\U533a";
 Thoroughfare = "\U5434\U4e2d\U8def699";
 }
 
 */


@end
