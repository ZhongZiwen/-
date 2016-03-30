//
//  AddTagsViewController.h
//  lianluozhongxin
//  新增标签
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface AddTagsViewController : AppsBaseViewController

///刷新标签列表
@property (nonatomic, copy) void (^NotifyTagsList)(void);

@end
