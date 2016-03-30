//
//  DetailStaffsViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailStaffModel, Code;

@interface DetailStaffsViewController : UIViewController

@property (copy, nonatomic) NSString *addStaffsPath;        // 添加成员
@property (copy, nonatomic) NSString *deleteStaffPath;      // 删除员工
@property (copy, nonatomic) NSString *updateAccessPath;     // 修改权限
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) Code *editCode;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
