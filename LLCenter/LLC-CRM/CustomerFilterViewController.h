//
//  CustomerFilterViewController.h
//  lianluozhongxin
//   客户管理-筛选
//  Created by sungoin-zjp on 15-7-4.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface CustomerFilterViewController : AppsBaseViewController






@property (strong, nonatomic) IBOutlet UIView *viewFilter;

@property (strong, nonatomic) IBOutlet UIButton *btnByTag;
@property (strong, nonatomic) IBOutlet UILabel *labelByTag;
@property (strong, nonatomic) IBOutlet UIImageView *imgArrowTag;
@property (strong, nonatomic) IBOutlet UIImageView *imgLine1;
@property (strong, nonatomic) IBOutlet UIButton *btnByBelong;
@property (strong, nonatomic) IBOutlet UILabel *labelByBelong;
@property (strong, nonatomic) IBOutlet UIImageView *imgArrowBelong;
@property (strong, nonatomic) IBOutlet UIImageView *imgLine2;


///标签
@property (strong,nonatomic) NSString *customerStateFlag;
///所属者
@property (strong,nonatomic) NSString *ownerId;


- (IBAction)btnAction:(id)sender;


@property (strong, nonatomic) IBOutlet UIImageView *imgLineVSplit1;

@property (strong, nonatomic) IBOutlet UIImageView *imgLineVSplit2;





@property (nonatomic, copy) void (^RequestDataByFilter)(NSString *stateflagid,NSString *ownerid,BOOL isRequest);

@end
