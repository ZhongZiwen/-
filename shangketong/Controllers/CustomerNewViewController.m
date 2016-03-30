//
//  CustomerNewViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomerNewViewController.h"
#import "Helper.h"

@interface CustomerNewViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (void)presentImagePickerController;
@end

@implementation CustomerNewViewController

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
    
    [self.view beginLoading];
    [self sendRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Customer_New_WithParams:_params andBlock:^(id data, NSError *error) {
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
            // 插入业务类型行
            //            XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
            //            [self.form addFormSection:section atIndex:0];
            //            XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:@"type" rowType:XLFormRowDescriptorTypeText title:@"业务类型"];
            //            [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
            //            [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"textField.textColor"];
            //            [row.cellConfig setObject:[UIColor blackColor] forKey:@"textLabel.textColor"];
            //            row.value = _item.name;
            //            row.disabled = @1;
            //            [section addFormRow:row];
            
        }
        else if (error) {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^{
                    [self sendRequest];
                };
                [comRequest loginInBackground];
                return;
            }
            else {
                [self.view endLoading];
                [self.navigationController popViewControllerAnimated:YES];
            }
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
    [[Net_APIManager sharedManager] request_Customer_EditOrSave_WithParams:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^{
                    [self rightButtonItemPress];
                };
                [comRequest loginInBackground];
            }
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
        [[Net_APIManager sharedManager] request_Common_ScanningCard_WithPath:kNetPath_Customer_Scanning image:pickerImage params:_params block:^(id data, NSError *error) {
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
