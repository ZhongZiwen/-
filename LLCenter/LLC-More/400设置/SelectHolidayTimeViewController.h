//
//  SelectHolidayTimeViewController
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AppsBaseViewController.h"
@interface SelectHolidayTimeViewController : AppsBaseViewController{
    
}

@property(strong,nonatomic) NSString *holidayStartTime;
@property(strong,nonatomic) NSString *holidayEndTime;

///选择完成
@property (nonatomic, copy) void (^SelectDateTimeDoneBlock)(NSString *startTime,NSString *endTime);

@end
