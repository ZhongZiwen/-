//
//  OpportunityEditMainContactController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityEditMainContactController.h"
#import "ContactTableViewCell.h"
#import "Contact.h"

#define kCellIdentifier @"ContactTableViewCell"

@interface OpportunityEditMainContactController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

- (void)sendRequestToAssignMainContact:(Contact*)item;
@end

@implementation OpportunityEditMainContactController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequestToAssignMainContact:(Contact *)item {
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempParams setObject:item.id forKey:@"linkManId"];
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_SaleChance_AssignMainContact_WithParams:tempParams block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ContactTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    Contact *item = _sourceArray[indexPath.row];
    [cell configWithModel:item];
    if ([item.isTouchLinkMan isEqualToNumber:@0]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Contact *item = _sourceArray[indexPath.row];
    if ([item.isTouchLinkMan isEqualToNumber:@0]) {
        return;
    }
    
    Contact *selectedItem;
    for (Contact *tempItem in _sourceArray) {
        if ([tempItem.isTouchLinkMan isEqualToNumber:@0]) {
            selectedItem = tempItem;
            break;
        }
    }
    
    // 没有主联系人
    if (!selectedItem) {
        
        [self sendRequestToAssignMainContact:item];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"是否将%@设为此销售机会的主联系人？设定后，%@将不再是主联系人。", item.name, selectedItem.name] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confireAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self sendRequestToAssignMainContact:item];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:confireAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - setters  and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - 64];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
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
