//
//  OpportunityStageChanceController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityStageChanceController.h"
#import "OpportunityStage.h"
#import "NameIdModel.h"
#import "CustomActionSheet.h"

#define kCellIdentifier @"UITableViewCell"

@interface OpportunityStageChanceController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) OpportunityStage *tempSelectedStage;
@property (strong, nonatomic) CustomActionSheet *actionSheet;
@end

@implementation OpportunityStageChanceController

- (void)loadView {
    [super loadView];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(leftButtonPress)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"保存" target:self action:@selector(rightButtonPress)];
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    
    _tempSelectedStage = _currentStage;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Net_APIManager sharedManager] request_SaleChance_LostReasons_WithBlock:^(id data, NSError *error) {
            if (data) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary *tempDict in data[@"selects"]) {
                    NameIdModel *item = [NSObject objectOfClass:@"NameIdModel" fromJSON:tempDict];
                    [tempArray addObject:item];
                }
                
                self.actionSheet.sourceArray = tempArray;
            }
        }];
    });
    
    @weakify(self);
    self.actionSheet.title = @"请选择输单理由";
    _actionSheet.actionType = ActionSheetTypeFromNewContact;
    _actionSheet.selectedBlock = ^(NameIdModel *item, ActionSheetTypeFrom typeFrom) {
        @strongify(self);
        [self.params setObject:self.tempSelectedStage.id forKey:@"stageId"];
        [self.params setObject:item.id forKey:@"reasonId"];
        
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_SaleChance_ChangeStage_WithParams:self.params block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                if (self.refreshBlock) {
                    self.refreshBlock(self.tempSelectedStage);
                }
            }

            [self.navigationController popViewControllerAnimated:YES];
        }];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)leftButtonPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonPress {
    
    if ([_tempSelectedStage.value isEqualToString:@"输单"]) {
        [_actionSheet show];
        return;
    }
    
    [_params setObject:_tempSelectedStage.id forKey:@"stageId"];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_SaleChance_ChangeStage_WithParams:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            if (self.refreshBlock) {
                self.refreshBlock(self.tempSelectedStage);
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!section) {
        return _sourceArray.count - 1;
    }
    
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    OpportunityStage *item;
    if (!indexPath.section) {
        item = _sourceArray[indexPath.row];
    }else {
        item = _sourceArray.lastObject;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@(赢率%@%%)", item.value, item.rate];
    
    if ([item.id isEqualToString:_tempSelectedStage.id]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OpportunityStage *item;
    if (!indexPath.section) {
        item = _sourceArray[indexPath.row];
    }else {
        item = _sourceArray.lastObject;
    }
    
    _tempSelectedStage = item;
    
    [_tableView reloadData];
}

#pragma mark - setters and getters
//- (void)setMarkIndexPath:(NSIndexPath *)markIndexPath {
//    if (_markIndexPath == markIndexPath)
//        return;
//    
//    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:_markIndexPath];
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    
//    _markIndexPath = markIndexPath;
//    cell = [_tableView cellForRowAtIndexPath:_markIndexPath];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
//}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _tableView;
}

- (CustomActionSheet*)actionSheet {
    if (!_actionSheet) {
        _actionSheet = [[CustomActionSheet alloc] init];
    }
    return _actionSheet;
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
