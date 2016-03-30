//
//  OpportunityNewViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityNewViewController.h"

@interface OpportunityNewViewController ()

@end

@implementation OpportunityNewViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(backButtonItemPress)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"保存" target:self action:@selector(rightButtonItemPress)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    
    [self.view beginLoading];
    [self sendRequestInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequestInit {
    [[Net_APIManager sharedManager] request_SaleChance_NewInit_WithParams:_params block:^(id data, NSError *error) {
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"columns"]) {
                ColumnModel *item = [NSObject objectOfClass:@"ColumnModel" fromJSON:tempDict];
                for (NSDictionary *tempSelectDict in tempDict[@"select"]) {
                    ColumnSelectModel *selectItem = [NSObject objectOfClass:@"ColumnSelectModel" fromJSON:tempSelectDict];
                    [item.selectArray addObject:selectItem];
                }
                [item configResultWithDictionary:tempDict];
                [tempArray addObject:item];
            }
            self.sourceArray = tempArray;
            [self configXLForm];
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^{
                    [self sendRequestInit];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
    }];
}

#pragma mark - event response
- (void)backButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemPress {
   
    [self.view endEditing:YES];

    NSString *jsonString = [self jsonString];
    if (!jsonString) {
        return;
    }
    
    [_params setObject:jsonString forKey:@"json"];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_SaleChance_EditOrSave_WithParams:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
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
