//
//  SearchResultViewController.h
//  shangketong
//  搜索结果页面-公用
//  Created by sungoin-zjp on 15-6-24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultViewController : UIViewController
@property(strong,nonatomic) UITableView *tableviewSearch;
@property(strong,nonatomic) NSMutableArray *arraySearch;

///用来标记不同的view 加载其对应的cell
@property(strong,nonatomic)NSString *typeFromView;

///搜索关键词
@property(strong,nonatomic)NSString *keyWord;
@end
