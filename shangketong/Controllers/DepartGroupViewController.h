//
//  DepartGroupViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, DepartGroupViewControllerType) {
    DepartGroupViewControllerTypeDepartment = 0,    // 公司部门
    DepartGroupViewControllerTypeGroup              // 群组
};

@interface DepartGroupViewController : BaseViewController

@property (assign, nonatomic) DepartGroupViewControllerType type;
@end
