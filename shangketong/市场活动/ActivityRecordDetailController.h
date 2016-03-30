//
//  ActivityRecordDetailController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Record;

@interface ActivityRecordDetailController : UIViewController

@property (copy, nonatomic) void(^deleteRecordSuccessBlock)(void);

@property (strong, nonatomic) Record *record;
@property (assign, nonatomic) BOOL isAnimateInput;
@end
