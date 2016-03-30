//
//  DefaultSettingViewController.h
//  lianluozhongxin
//  默认设置
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface DefaultSettingViewController : AppsBaseViewController

@property (strong, nonatomic) IBOutlet UIView *viewContentBg;


@property (strong, nonatomic) IBOutlet UIButton *btnCompanyCustomer;
@property (strong, nonatomic) IBOutlet UIButton *btnPersonalCustomer;


- (IBAction)selectCustomerType:(id)sender;



@end
