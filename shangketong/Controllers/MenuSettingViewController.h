//
//  MenuSettingViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
typedef NS_ENUM(NSInteger, DataSourceType) {
    DataSourceTypeCRM,
    DataSourceTypeOffice,
};

@interface MenuSettingViewController : BaseViewController

@property (nonatomic, assign) DataSourceType sourceType;
@property (nonatomic, strong) NSArray *dataSourceOld;

@property (nonatomic, copy) void (^notifyModuleOptions)(NSArray *opstions);
@end
