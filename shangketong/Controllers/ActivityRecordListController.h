//
//  ActivityRecordListController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityRecordListController : UIViewController

@property (copy, nonatomic) NSString *startTime;
@property (copy, nonatomic) NSString *endTime;
@property (copy, nonatomic) NSString *typeId;
@property (strong, nonatomic) NSNumber *userId;
@end
