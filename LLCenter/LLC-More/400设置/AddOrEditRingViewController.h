//
//  AddOrEditRingViewController.h
//  lianluozhongxin
//   新建、编辑铃声
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface AddOrEditRingViewController : AppsBaseViewController


///新增/编辑  add  edit
@property(strong,nonatomic) NSString *actionType;
@property(strong,nonatomic) NSDictionary *detail;


///刷新炫铃列表
@property (nonatomic, copy) void (^NotifyRingList)(void);

@end
