//
//  ConfirmedPlanController.m
//  shangketong
//
//  Created by 蒋 on 15/8/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ConfirmedPlanController.h"
#import "ConfirmedPlanCell.h"
#import "CommonFuntion.h"
#import "AFNHttp.h"
#import "CommonConstant.h"
#import <MBProgressHUD.h>
#import "ScheduleDetailViewController.h"

@interface ConfirmedPlanController ()
@property (nonatomic, assign) long long planID; //日程id
@property (nonatomic, assign) long long userID; //接受人id
@property (nonatomic, strong) NSMutableArray *dataSoucerArray;
@property (nonatomic, assign) long long scheduleId;
@end

@implementation ConfirmedPlanController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    self.tableViewConfirmed.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    self.tableViewConfirmed.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    _dataSoucerArray = [NSMutableArray arrayWithArray:_dataSoucerArrayOld];
    
    UIView *V = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableViewConfirmed setTableFooterView:V];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_backDataSoucerBlock) {
        _backDataSoucerBlock(_dataSoucerArray);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_dataSoucerArray && [_dataSoucerArray count] != 0) {
        return [_dataSoucerArray count];
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConfirmedPlanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConfirmedPlanCellIdentifier"];
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ConfirmedPlanCell" owner:self options:nil];
        cell = (ConfirmedPlanCell *)[array objectAtIndex:0];
        [cell awakeFromNib];
        [cell setFrameForAllPhone];
    }
    __weak typeof(self) weak_self = self;
    cell.backOnePlanIDBlock = ^(long long scheduleId) {
        _scheduleId = scheduleId;
        [weak_self confirmeOnePlan];
    };
     NSDictionary *dict = _dataSoucerArray[indexPath.row];
    [cell setCellValue:dict];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //需要作区分
    NSDictionary *dic = _dataSoucerArray[indexPath.row];
    ScheduleDetailViewController *scheduleDetailController = [[ScheduleDetailViewController alloc] init];
    scheduleDetailController.scheduleId = [[dic objectForKey:@"id"] integerValue];
    scheduleDetailController.RefreshForPlanControllerBlock = ^{
        [_dataSoucerArray removeObjectAtIndex:indexPath.row];
        [_tableViewConfirmed reloadData];
    };
    [self.navigationController pushViewController:scheduleDetailController animated:YES];
}

- (void)confirmeOnePlan {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.tableViewConfirmed];
    [self.tableViewConfirmed addSubview:hud];
    [hud show:YES];
    //scheduleId日程id
    //staffId接受日程用户id
    __weak typeof(self) weak_self = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSString stringWithFormat:@"%lld", _scheduleId] forKey:@"scheduleId"];
    [params setObject:appDelegateAccessor.moudle.userId forKey:@"staffId"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_SCHEDULE_GET_RECEIVE] params:params success:^(id responseObj) {
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            [_dataSoucerArray removeAllObjects];
            [weak_self getDataSoucerForBeConfirmed];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self confirmeOnePlan];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = @"";
            desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"接受失败";
            }
            kShowHUD(desc,nil);
        }
        [hud hide:YES];
    } failure:^(NSError *error) {
        NSLog(@"接受任务失败error%@", error);
        [hud hide:YES];
        [CommonFuntion showToast:NET_ERROR inView:self.view];
    }];
}
#pragma mark - 获取待接收日程
- (void)getDataSoucerForBeConfirmed {
    __weak typeof(self) weak_self = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_SCHEDULE_GET_BECONFIRMED] params:params success:^(id responseObj) {
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if (responseObj && [responseObj objectForKey:@"schedules"]) {
                [_dataSoucerArray addObjectsFromArray:[responseObj objectForKey:@"schedules"]];
                if (_dataSoucerArray.count == 0) {
                    [weak_self.navigationController popViewControllerAnimated:YES];
                }
            } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
                __weak typeof(self) weak_self = self;
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [weak_self getDataSoucerForBeConfirmed];
                };
                [comRequest loginInBackground];
            }
            [weak_self.tableViewConfirmed reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"重新获取数据：error%@", error);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
