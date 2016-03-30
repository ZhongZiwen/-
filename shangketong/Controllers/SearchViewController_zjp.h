//
//  SearchViewController.h
//  shangketong
//  搜索页面-公用
//  Created by sungoin-zjp on 15-6-24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController_zjp : UIViewController

@property(strong,nonatomic) UITableView *tableviewSearch;
@property(strong,nonatomic) NSMutableArray *arraySearch;

///用来标记不同的view 加载其对应的cell
@property(strong,nonatomic)NSString *typeFromView;

///用来标记不同的搜索状态  默认/编辑
///默认状态 对应SearchHistoryCell  编辑状态则根据typeFromView来匹配
@property(strong,nonatomic)NSString *typeSearchStatus;

///标记是否跳转到搜索结果页面  no  其他
@property(strong,nonatomic)NSString *typeGoSearchResult;

@end
