//
//  ContactNewViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ContactNewViewController.h"
#import "Helper.h"
#import "NameIdModel.h"
#import "CustomActionSheet.h"

@interface ContactNewViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) CustomActionSheet *actionSheet;

- (void)presentImagePickerController;
@end

@implementation ContactNewViewController

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
    
    @weakify(self);
    self.actionSheet.title = @"选择客户公海池分组";
    _actionSheet.actionType = ActionSheetTypeFromNewContact;
    _actionSheet.selectedBlock = ^(NameIdModel *item, ActionSheetTypeFrom typeFrom) {
        @strongify(self);
        [self.params setObject:item.id forKey:@"customerPoolId"];
        [self sendRequest];
    };
    
    if (_isScanning) {
        [_params setObject:@1 forKey:@"type"];
    }
    
    [self.view beginLoading];
    [self sendRequestInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequestInit {
    [[Net_APIManager sharedManager] request_Contact_NewInit_WithPath:_requestInitPath params:_params block:^(id data, NSError *error) {
        if (data) {
            [self.view endLoading];
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
            
        }else {
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
        [[Net_APIManager sharedManager] request_Common_ScanningCard_WithPath:_requestScanningPath image:pickerImage params:_params block:^(id data, NSError *error) {
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

    [self.view endEditing:YES];
    
    NSString *jsonString = [self jsonString];
    if (!jsonString) {
        return;
    }
    
    [_params setObject:jsonString forKey:@"json"];
    
    // 联系人扫描，并且客户池开启的时候
    // 客户池不开启将不需要客户池分组这些操作
    if (_isScanning && !appDelegateAccessor.moudle.isOpen_customerPool) {
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Contact_ValidateCustomer_WithParams:_params block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                if ([data[@"customerGroupStatus"] isEqualToNumber:@1]) {
                    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSDictionary *tempDict in data[@"groups"]) {
                        NameIdModel *item = [NSObject objectOfClass:@"NameIdModel" fromJSON:tempDict];
                        [tempArray addObject:item];
                    }
                    
                    _actionSheet.sourceArray = tempArray;
                    [_actionSheet show];
                }
                else if ([data[@"customerGroupStatus"] isEqualToNumber:@2]) {
                    [NSObject showHudTipStr:@"没有可用的客户池分组，请联系管理员"];
                }
                else if ([data[@"customerGroupStatus"] isEqualToNumber:@3]) {
                    [self sendRequest];
                }
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
        
        return;
    }
    
    [self sendRequest];
}

- (void)sendRequest {
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Contact_EditOrSave_WithPath:_requestAddPath params:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            [NSObject showHudTipStr:@"新建成功"];
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [self sendRequest];
                };
                [comRequest loginInBackground];
            }
        }
    }];
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
