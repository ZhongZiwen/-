//
//  MemberViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DepartGroupModel;

typedef NS_ENUM(NSInteger, MemberViewControllerType) {
    MemberViewControllerTypeDepartment,
    MemberViewControllerTypeGroup
};

@interface MemberViewController : UIViewController

@property (assign, nonatomic) MemberViewControllerType memberType;
@property (strong, nonatomic) DepartGroupModel *item;
@end
