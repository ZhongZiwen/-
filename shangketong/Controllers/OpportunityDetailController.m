//
//  OpportunityDetailController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityDetailController.h"
#import "OpportunityHeaderView.h"
#import "OpportunityStageChanceController.h"
#import "Customer.h"
#import "CustomerDetailViewController.h"
#import "DetailStaffsViewController.h"

@interface OpportunityDetailController ()

@property (strong, nonatomic) OpportunityHeaderView *tableHeaderView;
@end

@implementation OpportunityDetailController

- (void)loadView {
    [super loadView];
    
    self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    @weakify(self);
    // 销售阶段
    _tableHeaderView.opportunityStageBlock = ^{
        @strongify(self);
        for (Code *tempCode in self.detailItem.codesArray) {
            if ([tempCode.code isEqualToNumber:@3005] && ![tempCode.status integerValue]) {
                OpportunityStageChanceController *stageChangeController = [[OpportunityStageChanceController alloc] init];
                stageChangeController.title = @"修改销售阶段";
                stageChangeController.currentStage = self.detailItem.currentStage;
                stageChangeController.sourceArray = self.detailItem.stageListArray;
                stageChangeController.refreshBlock = ^(OpportunityStage *item) {
                    self.detailItem.currentStage = item;
                    [self configTableViewHeaderView];
                };
                [self.navigationController pushViewController:stageChangeController animated:YES];
                break;
            }
        }
    };
    
    // 客户
    _tableHeaderView.customerBlock = ^{
        @strongify(self);
        Customer *customer = [[Customer alloc] init];
        customer.id = self.detailItem.customer.id;
        customer.name = self.detailItem.customer.name;
        CustomerDetailViewController *customerDetailController = [[CustomerDetailViewController alloc] init];
        customerDetailController.title = @"客户";
        customerDetailController.id = customer.id;
        [self.navigationController pushViewController:customerDetailController animated:YES];
    };
    
    // 团队成员
    _tableHeaderView.staffsBlock = ^{
        @strongify(self);
        DetailStaffsViewController *staffsController = [[DetailStaffsViewController alloc] init];
        staffsController.title = @"团队成员";
        for (Code *tempItem in self.detailItem.codesArray) {
            if ([tempItem.code isEqualToNumber:@3002]) {
                staffsController.editCode = tempItem;
                break;
            }
        }
        staffsController.sourceArray = self.detailItem.staffsArray;
        staffsController.addStaffsPath = kNetPath_SaleChance_AddStaffs;
        staffsController.deleteStaffPath = kNetPath_SaleChance_DeleteStaff;
        staffsController.updateAccessPath = kNetPath_SaleChance_UpdateAccess;
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

- (OpportunityHeaderView*)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[OpportunityHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
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
