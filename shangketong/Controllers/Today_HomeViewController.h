//
//  Today_HomeViewController.h
//  shangketong
// 今日
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface Today_HomeViewController : UIViewController<CLLocationManagerDelegate>

@property(strong,nonatomic)CLLocationManager *locationManager;

@property(strong,nonatomic) UITableView *tableviewTodaySchedule;
@property(strong,nonatomic) NSMutableArray *arrayTodaySchedule;

@property (assign)BOOL isOpen;
@property (nonatomic,retain)NSIndexPath *selectIndex;
@end
