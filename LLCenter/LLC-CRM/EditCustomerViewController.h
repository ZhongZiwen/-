//
//  EditCustomerViewController.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface EditCustomerViewController : AppsBaseViewController

@property(nonatomic,strong) NSDictionary *cusDetails;
@property(nonatomic,strong) NSDictionary *mainLinkMan;
@property(nonatomic,strong) NSArray *arrayCusTags;

///刷新客户详细信息
@property (nonatomic, copy) void (^NotifyCustomerDetails)(void);

@end
