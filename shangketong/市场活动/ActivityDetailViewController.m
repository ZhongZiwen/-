//
//  ActivityDetailViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 16/1/6.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "HeaderView.h"
#import "DetailStateChangeController.h"
#import "DetailStaffsViewController.h"

@interface ActivityDetailViewController ()

@property (strong, nonatomic) HeaderView *tableViewHeaderView;
@end

@implementation ActivityDetailViewController

- (void)loadView {
    [super loadView];
    
    self.tableView.tableHeaderView = self.tableViewHeaderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    @weakify(self);
    _tableViewHeaderView.stateBtnClickedBlock = ^{
        @strongify(self);
        for (Code *tempCode in self.detailItem.codesArray) {
            if ([tempCode.code isEqualToNumber:@1005] && ![tempCode.status integerValue]) {
                DetailStateChangeController *stateChangeController = [[DetailStateChangeController alloc] init];
                stateChangeController.title = @"修改活动状态";
                stateChangeController.changeType = DetailStateChangeTypeActivity;
                stateChangeController.currentState = self.detailItem.activityState;
                stateChangeController.sourceArray = self.detailItem.activityListArray;
                stateChangeController.refreshBlock = ^(ValueIdModel *item) {
                    self.detailItem.activityState = item;
                    [self configTableViewHeaderView];
                };
                [self.navigationController pushViewController:stateChangeController animated:YES];
                break;
            }
        }
    };
    _tableViewHeaderView.staffClickedBlock = ^{
        @strongify(self);
        DetailStaffsViewController *staffsController = [[DetailStaffsViewController alloc] init];
        staffsController.title = @"团队成员";
        for (Code *tempItem in self.detailItem.codesArray) {
            if ([tempItem.code isEqualToNumber:@1002]) {
                staffsController.editCode = tempItem;
                break;
            }
        }
        staffsController.sourceArray = self.detailItem.staffsArray;
        staffsController.addStaffsPath = kNetPath_Activity_AddStaffs;
        staffsController.deleteStaffPath = kNetPath_Activity_DeleteStaff;
        staffsController.updateAccessPath = kNetPath_Activity_UpdateAccess;
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
    [self.tableViewHeaderView configWithModel:self.detailItem];
}

#pragma mark - setters and getters
- (HeaderView*)tableViewHeaderView {
    if (!_tableViewHeaderView) {
        _tableViewHeaderView = [[HeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    }
    return _tableViewHeaderView;
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
