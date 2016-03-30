//
//  ApprovalApplyViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalApplyViewController.h"
#import "ApprovalNewApplyViewController.h"
#import "AFNHttp.h"

#define kCellIdentifier @"UITableViewCell"

@interface ApprovalApplyViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ApprovalApplyViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;

    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (_applyType == ApplyFlowTypeApprovalType) {
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:COMMON_PARAMS];
        [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Approve_Type] params:params success:^(id responseObj) {
            NSLog(@"responseObj:%@",responseObj);
            if (![[responseObj objectForKey:@"status"] integerValue]) {
                for (NSDictionary *tempDict in [responseObj objectForKey:@"list"]) {
                    [_sourceArray addObject:tempDict];
                }
                [_tableView reloadData];
            }
        } failure:^(NSError *error) {
            
        }];
    }else {
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:COMMON_PARAMS];
        [params setObject:@(_approvalTypeId) forKey:@"id"];
        [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Approve_Flow] params:params success:^(id responseObj) {
            NSLog(@"responseObj:%@",responseObj);
            if (![[responseObj objectForKey:@"status"] integerValue]) {
                for (NSDictionary *tempDict in [responseObj objectForKey:@"list"]) {
                    [_sourceArray addObject:tempDict];
                }
                [_tableView reloadData];
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_applyType == ApplyFlowTypeApprovalType) {
        return 1;
    }
    return _sourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_applyType == ApplyFlowTypeApprovalType) {
        return _sourceArray.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (_applyType == ApplyFlowTypeApprovalType) {
        return 0.05f;
    }else{
        NSString *remark = [_sourceArray[section] safeObjectForKey:@"remark"];
        if (remark && remark.length > 0) {
            CGSize sizeRemark = [CommonFuntion getSizeOfContents:remark Font:[UIFont systemFontOfSize:14.0] withWidth:kScreen_Width-30 withHeight:MAX_WIDTH_OR_HEIGHT];
            return sizeRemark.height +20;
        }
        return 1.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_applyType == ApplyFlowTypeApprovalType) {
        return nil;
    }
    NSString *remark = [_sourceArray[section] safeObjectForKey:@"remark"];
    if (remark && remark.length > 0) {
        CGSize sizeRemark = [CommonFuntion getSizeOfContents:remark Font:[UIFont systemFontOfSize:14.0] withWidth:kScreen_Width-30 withHeight:MAX_WIDTH_OR_HEIGHT];
        
        UIView *footviewDetail = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, sizeRemark.height+20)];
        footviewDetail.backgroundColor = kView_BG_Color;
        footviewDetail.layer.borderWidth = 0.5;
        footviewDetail.layer.borderColor = kView_BG_Color.CGColor;
        
        UILabel *labelRemark = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, kScreen_Width-30, sizeRemark.height)];
        labelRemark.backgroundColor = kView_BG_Color;
        labelRemark.font = [UIFont systemFontOfSize:14.0];
        labelRemark.textColor = [UIColor lightGrayColor];
        labelRemark.numberOfLines = 0;
        labelRemark.lineBreakMode = NSLineBreakByWordWrapping;
        labelRemark.text = remark;
        
        [footviewDetail addSubview:labelRemark];
        
        return footviewDetail;
    }else{
        return  nil;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (_applyType == ApplyFlowTypeApprovalType) {
        cell.textLabel.text = [_sourceArray[indexPath.row] objectForKey:@"name"];
    }else {
        cell.textLabel.text = [_sourceArray[indexPath.section] objectForKey:@"name"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __weak typeof(self) weak_self = self;
    if (_applyType == ApplyFlowTypeApprovalType) {  // 选择流程
        ApprovalApplyViewController *applyController = [[ApprovalApplyViewController alloc] init];
        applyController.title = @"选择流程";
        applyController.approvalTypeId = [[_sourceArray[indexPath.row] objectForKey:@"id"] integerValue];
        applyController.applyType = ApplyFlowTypeApprovalFlow;
        applyController.refreshBlock = ^{
            if (weak_self.refreshBlock) {
                weak_self.refreshBlock();
            }
        };
        [self.navigationController pushViewController:applyController animated:YES];
        return;
    }
    
    // 填写申请表格
    ApprovalNewApplyViewController *newApplyController = [[ApprovalNewApplyViewController alloc] init];
    newApplyController.title = @"提交申请";
    newApplyController.applyId = [[_sourceArray[indexPath.section] objectForKey:@"id"] integerValue];
    newApplyController.applyTypeId = [[_sourceArray[indexPath.section] objectForKey:@"typeId"] integerValue];
    newApplyController.refreshBlock = ^{
        if (weak_self.refreshBlock) {
            weak_self.refreshBlock();
        }
    };
    [self.navigationController pushViewController:newApplyController animated:YES];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _tableView;
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
