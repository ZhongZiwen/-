//
//  POITableViewController.h
//  DemoMapViewPOI
//
//  Created by sungoin-zjp on 15-5-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@protocol SelectPOIDelegate;

@interface POITableViewController : UITableViewController

@property (assign, nonatomic) id <SelectPOIDelegate>delegate;

@property(strong,nonatomic)NSString *curLocationName;
@property(strong,nonatomic)NSString *curLocationStreet;
@property(strong,nonatomic) NSArray *poiArray;

@end


// 选择POI位置信息 在mapview中做定位刷新
@protocol SelectPOIDelegate<NSObject>
@optional
- (void)notifyMapViewBySelectedPOI:(MKMapItem *)mapItem;
@end