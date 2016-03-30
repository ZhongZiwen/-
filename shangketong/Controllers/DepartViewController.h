//
//  DepartViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DepartGroupModel;

@interface DepartViewController : UIViewController

@property (strong, nonatomic) DepartGroupModel *item;


///获取tabbar controller  items   groupOrDepartType 1001 1002
-(NSArray *)getTabBarItems:(DepartGroupModel *)item andType:(NSInteger)groupOrDepartType;
@end
