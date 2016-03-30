//
//  LeadDetailViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LeadDetailViewController.h"
#import "UIViewController+Expand.h"
#import "LeadHeaderView.h"
#import "AddressBookActionSheet.h"
#import "WebViewController.h"
#import "DetailStateChangeController.h"

@interface LeadDetailViewController ()

@property (strong, nonatomic) LeadHeaderView *tableHeaderView;
@end

@implementation LeadDetailViewController

- (void)loadView {
    [super loadView];
    
    self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    @weakify(self);
    self.tableHeaderView.phoneBtnClickedBlock = ^{
        @strongify(self);
        AddressBookActionSheet *actionSheet = [[AddressBookActionSheet alloc] initWithCancelTitle:@"取消" andMobile:self.detailItem.mobile andPhone:self.detailItem.phone];
        actionSheet.phoneBlock = ^(NSString *tel) {
            [self takePhoneWithNumber:tel];
        };
        actionSheet.msgBlock = ^(NSString *tel) {
            [self sendMessageWithRecipients:@[tel]];
        };
        [actionSheet show];
    };
    self.tableHeaderView.emailBtnClickedBlock = ^{
        @strongify(self);
        [self sendEmailWithRecipients:@[self.detailItem.email]];
    };
    self.tableHeaderView.positionBtnClickedBlock = ^{
        @strongify(self);
        NSString *urlStr = [NSString stringWithFormat:@"http://map.baidu.com/mobile/webapp/search/search/wd=%@&qt=s&searchFlag=bigBox&version=5&exptype=dep&c=undefined&src_from=webapp_all_bigbox/", self.detailItem.position];
        WebViewController *positionController = [WebViewController webViewControllerWithUrlStr:urlStr];
        [self.navigationController pushViewController:positionController animated:YES];
    };
    self.tableHeaderView.stateBtnClickedBlock = ^{
        @strongify(self);
        for (Code *tempCode in self.detailItem.codesArray) {
            if ([tempCode.code isEqualToNumber:@2005] && ![tempCode.status integerValue]) {
                DetailStateChangeController *stateChangeController = [[DetailStateChangeController alloc] init];
                stateChangeController.title = @"修改跟进状态";
                stateChangeController.changeType = DetailStateChangeTypeSaleLeads;
                stateChangeController.currentState = self.detailItem.followState;
                stateChangeController.sourceArray = self.detailItem.followListArray;
                stateChangeController.refreshBlock = ^(ValueIdModel *item) {
                    self.detailItem.followState = item;
                    [self configTableViewHeaderView];
                };
                [self.navigationController pushViewController:stateChangeController animated:YES];
                break;
            }
        }
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configTableViewHeaderView {
    [self.tableHeaderView configWithModel:self.detailItem];
}

- (LeadHeaderView*)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[LeadHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    }
    return _tableHeaderView;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
