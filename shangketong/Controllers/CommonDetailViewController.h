//
//  CommonDetailViewController.h
//  shangketong
//  CRM-详情页面
//  Created by sungoin-zjp on 15-6-8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CRMInfoType) {
    ///跟进记录
    InfoTypeRecord,
    ///详细资料
    InfoTypeDetails
};

@interface CommonDetailViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    int pageNumber;
    BOOL pageControlUsed;
}


@property(strong,nonatomic) UITableView *tableviewDetails;
@property(strong,nonatomic) NSDictionary *itemDetails;
@property(strong,nonatomic) NSDictionary *dicRecordDetails;
@property(strong,nonatomic) NSMutableArray *arrayRecordList;
@property(strong,nonatomic) NSMutableArray *arrayRecordDetails;

///用来标记ID
@property(assign,nonatomic) long long idOfDetails;

///活动类型
@property(strong,nonatomic) NSArray *arrayActivityType;
///model
@property(strong,nonatomic) NSArray *arrayActivitySheetMenu;


///客户1   销售机会2  联系人3  销售线索4  市场活动5
@property(assign,nonatomic) NSInteger typeOfDetail;

///团队成员
@property(strong,nonatomic) NSArray *arrayContacts;

///销售机会 10 联系人11 日程任务12 审批13 文档14 销售线索15 产品16 客户17
@property(strong,nonatomic) NSDictionary *dicGroupHeadSum;

///单位
@property(strong,nonatomic) NSString *currencyUnit;
///销售机会 分组名称
@property(strong,nonatomic) NSString *groupNameOfSaleOpportunity;

///顶部view
@property (strong, nonatomic) IBOutlet UIView *headScrollview;
@property (nonatomic, retain) NSMutableArray *headviews;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIImageView *imgHeadViewBg;


@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) IBOutlet UIView *headviewDetail1;
@property (strong, nonatomic) IBOutlet UIView *headviewDetail2;
@property (strong, nonatomic) IBOutlet UIView *headviewDetail3;
@property (strong, nonatomic) IBOutlet UIView *headviewDetail4;


#pragma mark- top head details1
///拨打电话  消息  地址
@property (strong, nonatomic) IBOutlet UIButton *btnCall;
@property (strong, nonatomic) IBOutlet UIButton *btnMsg;
@property (strong, nonatomic) IBOutlet UIButton *btnAddress;

/// 客户  标题  图标 （2天后回收） 图标
@property (strong, nonatomic) IBOutlet UILabel *labelDetails1Title;
@property (strong, nonatomic) IBOutlet UIButton *btnDetails1TagIcon;
@property (strong, nonatomic) IBOutlet UIButton *btnDetails1ExtraInfo;
@property (strong, nonatomic) IBOutlet UIButton *btnDetails1ExtraIcon;


///联系人
@property (strong, nonatomic) IBOutlet UIButton *btnDetails1LeftName;
@property (strong, nonatomic) IBOutlet UIButton *btnDetails1RightName;
@property (strong, nonatomic) IBOutlet UIImageView *imgDetails1Line;


#pragma mark- top head details2

@property (strong, nonatomic) IBOutlet UILabel *labelDetails2Title;
@property (strong, nonatomic) IBOutlet UILabel *labelDetails2Infos;
@property (strong, nonatomic) IBOutlet UIButton *btnDetails2Icon;
@property (strong, nonatomic) IBOutlet UIButton *btnDetails2Status;
@property (strong, nonatomic) IBOutlet UIButton *btnDetails2RightIcon;


#pragma mark- top head details3

@property (strong, nonatomic) IBOutlet UILabel *labelDetails3Tiltle;
@property (strong, nonatomic) IBOutlet UIButton *btnDetails3LeftIcon;
@property (strong, nonatomic) IBOutlet UIButton *btnDetails3Status;
@property (strong, nonatomic) IBOutlet UIButton *btnDetails3RightIcon;



#pragma mark- tableview headview
///使用Tag标记
///销售机会 10 联系人11 日程任务12 审批13 文档14 销售线索15 产品16

@property (strong, nonatomic) IBOutlet UIView *headview;
@property (strong, nonatomic) IBOutlet UIScrollView *groupHeadScrollview;

@property (strong, nonatomic) IBOutlet UIButton *btnGroupHead1;
@property (strong, nonatomic) IBOutlet UIButton *btnGroupHead2;
@property (strong, nonatomic) IBOutlet UIButton *btnGroupHead3;
@property (strong, nonatomic) IBOutlet UIButton *btnGroupHead4;
@property (strong, nonatomic) IBOutlet UIButton *btnGroupHead5;


@end
