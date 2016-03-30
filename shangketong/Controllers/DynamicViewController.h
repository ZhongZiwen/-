//
//  DynamicViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DepartGroupModel;

typedef NS_ENUM(NSInteger, DynamicViewControllerType) {
    DynamicViewControllerTypeDepartment,
    DynamicViewControllerTypeGroup
};

@interface DynamicViewController : UIViewController

@property (strong, nonatomic) DepartGroupModel *item;
@property (assign, nonatomic) DynamicViewControllerType dynamicType;
@end
