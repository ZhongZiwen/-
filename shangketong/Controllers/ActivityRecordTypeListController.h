//
//  ActivityRecordTypeListController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityRecordTypeListController : UIViewController

@property (strong, nonatomic) NSNumber *userId;
@property (copy, nonatomic) NSString *typeId;
@property (strong, nonatomic) NSArray *sourceArray;
@end
