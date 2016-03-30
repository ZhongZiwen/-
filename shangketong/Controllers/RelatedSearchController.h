//
//  RelatedSearchController.h
//  shangketong
//
//  Created by 蒋 on 15/12/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RelatedSearchController : UIViewController
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) NSInteger activityType; //类型
@property (nonatomic, strong) NSString *titleName;
@property (nonatomic, copy) void(^BlackUpdateDataSourceBlock)(NSDictionary *);

///用来标记是不是审批模块的 'approval'
@property(nonatomic,strong) NSString  *flagOfRelevance;
///当前选择的类型
@property(nonatomic,strong) NSString  *businessCode;
@property (nonatomic, assign) NSInteger activityIndex; //类型

@end
