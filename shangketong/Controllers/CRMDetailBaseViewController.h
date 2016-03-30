//
//  CRMDetailBaseViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 16/1/6.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "BaseViewController.h"
#import "CRMDetail.h"

@interface CRMDetailBaseViewController : BaseViewController

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) CRMDetail *detailItem;
@property (strong, nonatomic) UITableView *tableView;

- (void)sendRecordWithObj:(Record*)record;
- (void)sendRequestForDetail;
- (void)sendRequestForFollowRecord;
- (void)sendRequestForActivityRecordType;
- (void)configTableViewHeaderView;
@end
