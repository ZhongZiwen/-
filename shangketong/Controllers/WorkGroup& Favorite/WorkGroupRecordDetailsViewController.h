//
//  WorkGroupRecordDetailsViewController.h
//  shangketong
//  动态/收藏 详情
//  Created by sungoin-zjp on 15-6-12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AppDelegate.h"
#import "WorkGroupRecordViewController.h"

@interface WorkGroupRecordDetailsViewController : BaseViewController

@property(strong,nonatomic) UITableView *tableviewWorkGroupReviews;


@property(strong,nonatomic) NSMutableArray *arrayWorkGroupReview;

///详情
@property(strong,nonatomic)NSMutableDictionary *dicWorkGroupDetails;
@property(strong,nonatomic)NSDictionary *dicWorkGroupDetailsOld;
///是否显示键盘 yes no
@property(strong,nonatomic)NSString *isShowKeyBoardView;

///当前详情是正常还是转发  normal  forward
@property(strong,nonatomic)NSString *flagOfDetails;
///当前详情所在下标  用于修改本地数据
@property(assign,nonatomic) NSInteger sectionOfDic;
///更新赞的状态 且数量+1
@property (nonatomic, copy) void (^UpdatePriaseStatus)(NSInteger section);
///更新收藏与未收藏的状态 根据action
@property (nonatomic, copy) void (^UpdateFavStatus)(NSInteger section,NSString *action);
///删除动态更新本地数据
@property (nonatomic, copy) void (^DeleteTrendStatus)(NSInteger section);
///评论动态个数更新本地数据  ++ / --
@property (nonatomic, copy) void (^CommentTrendStatus)(NSInteger section,NSString *optionFlag);


@property (nonatomic, copy) void (^UpdateByForwardTrend)(void);
@property (nonatomic, copy) void (^BlackFreshenBlock)();
@property (nonatomic, assign) PushControllerType sourceType;

@end
