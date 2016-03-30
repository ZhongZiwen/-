//
//  LLCCustomerDetailViewController.h
//  lianluozhongxin
//  客户管理-详细信息
//  Created by sungoin-zjp on 15-7-2.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLCCustomerDetailViewController : AppsBaseViewController

@property (strong, nonatomic) IBOutlet UITableView *tableviewDetails;

@property(strong,nonatomic) NSString *customerId;

@property(strong,nonatomic) NSDictionary *dicDetails;
///业务、通讯日志
@property(strong,nonatomic) NSMutableArray *arrayDetails;
///业务、通讯日志 组织之后
@property(strong,nonatomic) NSMutableArray *arrayDetailsNew;


///HeadView

@property (strong, nonatomic) IBOutlet UIView *viewHeadInfos;

///基本信息
@property (strong, nonatomic) IBOutlet UIView *viewHeadBaseInfo;
@property (strong, nonatomic) IBOutlet UIImageView *imgIconBaseInfo;
@property (strong, nonatomic) IBOutlet UILabel *labelTagBaseInfo;
@property (strong, nonatomic) IBOutlet UILabel *labelContantMain;
@property (strong, nonatomic) IBOutlet UILabel *labelCompanyName;
@property (strong, nonatomic) IBOutlet UILabel *labelBelong;
@property (strong, nonatomic) IBOutlet UILabel *labelTagBelong;

@property (strong, nonatomic) IBOutlet UIButton *btnMoreBaseInfo;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollviewTag;






/// 联系信息
@property (strong, nonatomic) IBOutlet UIView *viewHeadContactWay;
@property (strong, nonatomic) IBOutlet UIImageView *imgIconContactWay;
@property (strong, nonatomic) IBOutlet UILabel *labelTagContactWay;
@property (strong, nonatomic) IBOutlet UILabel *labelPhoneNum;
@property (strong, nonatomic) IBOutlet UILabel *labelFamilyPhone;
@property (strong, nonatomic) IBOutlet UILabel *labelAddress;
@property (strong, nonatomic) IBOutlet UIButton *btnCallPhone;
@property (strong, nonatomic) IBOutlet UIButton *btnCallFamilyPhone;
@property (strong, nonatomic) IBOutlet UIButton *btnCopyAddress;





///刷新客户列表
@property (nonatomic, copy) void (^NotifyCustomerList)(void);

@end
