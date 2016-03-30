//
//  CRM_ContactNewViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CRM_ContactNewViewController.h"
#import "Helper.h"

@interface CRM_ContactNewViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableDictionary *params;

- (void)presentImagePickerController;
@end

@implementation CRM_ContactNewViewController

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
    [[Net_APIManager sharedManager] request_Common_ContactInit_WithParams:_params path:_requestInitPath block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"columns"]) {
                ColumnModel *item = [NSObject objectOfClass:@"ColumnModel" fromJSON:tempDict];
                for (NSDictionary *selectedDict in tempDict[@"select"]) {
                    ColumnSelectModel *selectItem = [NSObject objectOfClass:@"ColumnSelectModel" fromJSON:selectedDict];
                    [item.selectArray addObject:selectItem];
                }
                [item configResultWithDictionary:tempDict];
                [tempArray addObject:item];
            }
            self.sourceArray = tempArray;
            [self configXLForm];
            
            if (self.isScanning) {
                [self presentImagePickerController];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)presentImagePickerController {
    if (![Helper checkCameraAuthorizationStatus])
        return;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;//设置可编辑
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];//进入照相界面
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *pickerImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.view beginLoading];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Net_APIManager sharedManager] request_Common_ScanningCard_WithPath:_requestScanfPath image:pickerImage params:_params block:^(id data, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self.view endLoading];
                if (data) {
                    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSDictionary *tempDict in data[@"columns"]) {
                        ColumnModel *item = [NSObject objectOfClass:@"ColumnModel" fromJSON:tempDict];
                        for (NSDictionary *selectedDict in tempDict[@"select"]) {
                            ColumnSelectModel *selectItem = [NSObject objectOfClass:@"ColumnSelectModel" fromJSON:selectedDict];
                            [item.selectArray addObject:selectItem];
                        }
                        [item configResultWithDictionary:tempDict];
                        [tempArray addObject:item];
                    }
                    self.sourceArray = tempArray;
                    [self configXLForm];
                }
            });
        }];
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - event response
- (void)backButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemPress {
    NSString *jsonString = [self jsonString];
    if (!jsonString) {
        return;
    }
    
    [_params setObject:jsonString forKey:@"json"];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Contact_EditOrSave_WithPath:_requestSavePath params:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [self rightButtonItemPress];
                };
                [comRequest loginInBackground];
            }
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
