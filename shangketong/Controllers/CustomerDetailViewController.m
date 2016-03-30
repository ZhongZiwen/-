//
//  CustomerDetailViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomerDetailViewController.h"
#import "UIViewController+Expand.h"
#import "CustomerHeaderView.h"
#import "DetailStaffsViewController.h"
#import "AddressBookActionSheet.h"
#import "WebViewController.h"

@interface CustomerDetailViewController ()

@property (strong, nonatomic) CustomerHeaderView *tableHeaderView;
@end

@implementation CustomerDetailViewController

- (void)loadView {
    [super loadView];
    
    self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    @weakify(self);
    _tableHeaderView.phoneBtnClickedBlock = ^{
        @strongify(self);
        AddressBookActionSheet *actionSheet = [[AddressBookActionSheet alloc] initWithCancelTitle:@"取消" andMobile:nil andPhone:self.detailItem.phone];
        actionSheet.phoneBlock = ^(NSString *tel) {
            [self takePhoneWithNumber:tel];
        };
        [actionSheet show];
    };
    _tableHeaderView.positionBtnClickedBlock = ^{
        @strongify(self);
        NSString *urlStr = [NSString stringWithFormat:@"http://map.baidu.com/mobile/webapp/search/search/wd=%@&qt=s&searchFlag=bigBox&version=5&exptype=dep&c=undefined&src_from=webapp_all_bigbox/", self.detailItem.position];
        WebViewController *positionController = [WebViewController webViewControllerWithUrlStr:urlStr];
        [self.navigationController pushViewController:positionController animated:YES];
    };
    _tableHeaderView.staffClickedBlock = ^{
        @strongify(self);
        DetailStaffsViewController *staffsController = [[DetailStaffsViewController alloc] init];
        staffsController.title = @"团队成员";
        for (Code *tempItem in self.detailItem.codesArray) {
            if ([tempItem.code isEqualToNumber:@2002]) {
                staffsController.editCode = tempItem;
                break;
            }
        }
        staffsController.sourceArray = self.detailItem.staffsArray;
        staffsController.addStaffsPath = kNetPath_Customer_AddStaffs;
        staffsController.deleteStaffPath = kNetPath_Customer_DeleteStaff;
        staffsController.updateAccessPath = kNetPath_Customer_UpdateAccess;
        staffsController.refreshBlock = ^{
            // 排序
            NSArray *sortArray = [self.detailItem.staffsArray sortedArrayUsingComparator:^NSComparisonResult(DetailStaffModel *obj1, DetailStaffModel *obj2) {
                NSComparisonResult result = [obj1.staffLevel compare:obj2.staffLevel];
                return result;
            }];
            self.detailItem.staffsArray = [[NSMutableArray alloc] initWithArray:sortArray];
            [self configTableViewHeaderView];
        };
        [self.navigationController pushViewController:staffsController animated:YES];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configTableViewHeaderView {
    [self.tableHeaderView configWithObj:self.detailItem];
}

- (CustomerHeaderView*)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[CustomerHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
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
