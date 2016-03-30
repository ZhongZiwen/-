//
//  ActivityRecSearchResultController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityRecSearchResultController : UIViewController

@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSArray *usersArray;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@end
