//
//  AddMoreContactViewController.h
//  lianluozhongxin
//  新建联系人
//  Created by sungoin-zjp on 15-9-11.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface AddMoreContactViewController : AppsBaseViewController

@property(nonatomic,strong) NSDictionary *cusDetails;
///刷新联系人列表
@property (nonatomic, copy) void (^NotifyContactList)(void);

@end
