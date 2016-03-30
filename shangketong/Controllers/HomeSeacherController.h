//
//  HomeSeacherController.h
//
// 首页--搜索页面
//  Created by 蒋 on 15/7/13.
//  Copyright (c) 2015年 蒋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeSeacherController : UIViewController

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) NSInteger flagToHomeSearch; // 0首页 1知识库
@end
