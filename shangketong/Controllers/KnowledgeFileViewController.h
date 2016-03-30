//
//  KnowledgeFileViewController.h
//  shangketong
//  文件列表
//  Created by sungoin-zjp on 15-5-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface KnowledgeFileViewController : BaseViewController

@property(strong,nonatomic) UITableView *tableviewKnowledgeFile;
@property(strong,nonatomic)NSString *strTitle;

///知识库类型   -1 首页   0 公司（部门）知识库  1我的知识库  2 群组  3 CMR-详情
@property(assign,nonatomic) NSInteger typeKnowledge;
/// 请求类型  部门/文件  0 部门  1文件
@property(assign,nonatomic) NSInteger typeKnowledgeRequest;
///标记是否显示搜索栏    非知识库则不显示顶部搜索栏   知识库0
@property(assign,nonatomic) NSInteger typeKnowledgeSearchView;
///标记非知识库进入时   tableview frame 的判断标志 0 初次
@property(assign,nonatomic) NSInteger typeKnowledgeSearchViewFirst;
///文件夹id
@property (nonatomic, assign) long long dirId;
///  部门/群组 id
@property (nonatomic, assign) long long departmengOrGroupId;
///文件夹
//@property(strong,nonatomic)NSArray *arrayDirectories;
///文件
@property(strong,nonatomic)NSMutableArray *arrayFiles;
///部门
@property(strong,nonatomic)NSArray *arrayDepartments;

@end
