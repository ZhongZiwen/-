//
//  RecordSendViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RecordSendViewController.h"
#import "Helper.h"
#import "AddressBook.h"
#import "Customer.h"
#import "Record.h"
#import "RecordSendTextCell.h"
#import "RecordSendImagesCell.h"
#import "RecordSendVoiceView.h"
#import "PhotoAssetLibraryViewController.h"
#import "PhotoAssetModel.h"
#import "PhotoBrowserViewController.h"
#import "ExportAddressViewController.h"
#import "MapViewViewController.h"
#import "ContactNewSearchViewController.h"

#define kKeyboardView_Height 216.0
#define kCellIdentifier_text @"RecordSendTextCell"
#define kCellIdentifier_images @"RecordSendImagesCell"

typedef NS_ENUM(NSInteger, InputState) {
    InputStateSystem,
    InputStateVoice
};

@interface RecordSendViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoBrowserDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *footToolBar;
@property (strong, nonatomic) UIView *toolBar;
@property (strong, nonatomic) UIButton *locationButton;
@property (strong, nonatomic) UIImageView *locationIcon;
@property (strong, nonatomic) UILabel *locationTitle;
@property (strong, nonatomic) UIButton *deleteLocationButton;
@property (strong, nonatomic) UIButton *relationCustomerButton;     // 关联客户
@property (strong, nonatomic) UIImageView *relationCustomerIcon;
@property (strong, nonatomic) UILabel *relationCustomerTitle;
@property (strong, nonatomic) RecordSendVoiceView *voiceView;
@property (strong, nonatomic) PhotoAssetLibraryViewController *assetLibraryController;

@property (assign, nonatomic) NSTimeInterval animationDuration;
@property (assign, nonatomic) InputState inputState;
@end

@implementation RecordSendViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(cancelBtnClicked:)] animated:YES];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"发送" target:self action:@selector(sendRecord)];
    
//    @weakify(self);
//    RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal combineLatest:@[RACObserve(self, self.curRecord.recordContent)] reduce:^id (NSString *mdStr){
//        @strongify(self);
//        NSLog(@"mdStr = %@", mdStr);
//        return @(![self isEmptyRecord]);
//    }];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.footToolBar];
    [self.view addSubview:self.voiceView];
}

- (BOOL)inputViewIsFirstResponder {
    RecordSendTextCell *cell = (RecordSendTextCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return [cell.recordContentView isFirstResponder];
}

- (BOOL)inputViewBecomeFirstResponder {
    RecordSendTextCell *cell = (RecordSendTextCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell respondsToSelector:@selector(becomeFirstResponder)]) {
        [cell becomeFirstResponder];
    }
    return YES;
}

- (BOOL)inputViewResignFirstResponder {
    RecordSendTextCell *cell = (RecordSendTextCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell respondsToSelector:@selector(resignFirstResponder)]) {
        [cell resignFirstResponder];
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self inputViewBecomeFirstResponder];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _inputState = InputStateSystem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    @weakify(self);
    _voiceView.recordSuccessfully = ^(NSString *file, NSTimeInterval duration) {
        @strongify(self);
        self.curRecord.recordAudioFile = file;
        self.curRecord.recordAudioSecond = [NSNumber numberWithInteger:duration * 1000];
    };
    _voiceView.deleteRecordBlock = ^{
        @strongify(self);
        self.curRecord.recordAudioFile = nil;
        self.curRecord.recordAudioSecond = nil;
    };
    
    [self configLocation];
    if (_isQuickSignIn) {
        [self configRelationCustomer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)configLocation {
    _locationIcon.image = [UIImage imageNamed:_curRecord.position ? @"acitvity_position_press" : @"acitvity_position"];
    _locationTitle.textColor = _curRecord.position ? [UIColor iOS7lightBlueColor] : [UIColor iOS7lightGrayColor];
    
    NSString *titleStr = _curRecord.position ? : @"插入位置";
    
    CGFloat width = [titleStr getWidthWithFont:_locationTitle.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
    
    [_locationTitle setWidth:MIN(150, width)];
    _locationTitle.text = titleStr;
    [_locationButton setWidth:CGRectGetWidth(_locationTitle.bounds) + CGRectGetHeight(_locationButton.bounds) + 5 + CGRectGetWidth(_locationIcon.bounds)];
    
    if (_curRecord.position) {
        [_locationButton setWidth:CGRectGetWidth(_locationButton.bounds) + CGRectGetHeight(_locationButton.bounds) / 2];
        _deleteLocationButton.hidden = NO;
        [_deleteLocationButton setCenterX:CGRectGetMaxX(_locationButton.frame) - CGRectGetHeight(_locationButton.bounds) / 2];
    }
    else {
        _deleteLocationButton.hidden = YES;
    }
}

- (void)configRelationCustomer {
    
    CGFloat maxWidth = kScreen_Width - CGRectGetMaxX(_locationButton.frame) - 5 - 10;
    
    _relationCustomerIcon.image = [UIImage imageNamed:_curRecord.relationCustomerId ? @"account_icon_mini_select" : @"account_icon_mini_normal"];
    _relationCustomerTitle.textColor = _curRecord.relationCustomerId ? [UIColor iOS7lightBlueColor] : [UIColor iOS7lightGrayColor];
    
    NSString *titleStr = _curRecord.relationCustomerName ? : @"关联客户";
    
    CGFloat width = [titleStr getWidthWithFont:_relationCustomerTitle.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
    
    [_relationCustomerTitle setWidth:MIN(maxWidth - CGRectGetHeight(_locationButton.bounds) - 5 - CGRectGetWidth(_relationCustomerIcon.bounds), width)];
    _relationCustomerTitle.text = titleStr;
    [_relationCustomerButton setWidth:CGRectGetWidth(_relationCustomerTitle.bounds) + CGRectGetHeight(_relationCustomerButton.bounds) + 5 + CGRectGetWidth(_relationCustomerIcon.bounds)];
    [_relationCustomerButton setX:CGRectGetMaxX(_locationButton.frame) + 5];
//    [_relationCustomerButton setX:kScreen_Width - CGRectGetWidth(_relationCustomerButton.bounds) - 5];
}

#pragma mark - KeyBoard Notification
- (void)keyboardChange:(NSNotification*)aNotification{
    
    NSDictionary* userInfo = [aNotification userInfo];
    _animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:_animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
        CGFloat keyboardY = keyboardEndFrame.origin.y;
        if (ABS(keyboardY - kScreen_Height) < 0.1) {    // 收回键盘
            if (_inputState == InputStateVoice) {
                [_footToolBar setY:kScreen_Height - CGRectGetHeight(_footToolBar.bounds) - CGRectGetHeight(_voiceView.bounds)];
                [_voiceView setY:kScreen_Height - CGRectGetHeight(_voiceView.bounds)];
            }else {
                [_footToolBar setY:kScreen_Height - CGRectGetHeight(_footToolBar.bounds)];
                [_voiceView setY:kScreen_Height];
            }
        }else {
            [_footToolBar setY:keyboardY - CGRectGetHeight(_footToolBar.bounds)];
            if (_inputState == InputStateVoice) {
                [_voiceView setY:kScreen_Height];
                _inputState = InputStateSystem;
            }
        }
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (_inputState == InputStateSystem && scrollView == _tableView) {
        [self.view endEditing:YES];
        return;
    }

    if (_inputState == InputStateVoice) {
        _inputState = InputStateSystem;
        [UIView animateWithDuration:_animationDuration delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_voiceView setY:kScreen_Height];
            [_footToolBar setY:kScreen_Height - CGRectGetHeight(_footToolBar.bounds)];
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.row) {
        return [RecordSendTextCell cellHeight];
    }
    
    return [RecordSendImagesCell cellHeightWithObj:_curRecord];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    if (!indexPath.row) {
        RecordSendTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_text forIndexPath:indexPath];
        cell.recordContentView.text = _curRecord.recordContent;
        [cell.recordContentView.rac_textSignal subscribeNext:^(id x) {
            @strongify(self);
            self.curRecord.recordContent = [NSString stringWithFormat:@"%@", x];
        }];
        return cell;
    }
    
    RecordSendImagesCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_images forIndexPath:indexPath];
    [cell configWithRecord:_assetLibraryController.assetManager.selectedArray];
    cell.addImageBlock = ^{
        [self photoButtonPress];
    };
    cell.tapImageBlock = ^(NSInteger row) {
        PhotoBrowserViewController *photoBrowserController = [[PhotoBrowserViewController alloc] initWithDelegate:self];
        photoBrowserController.photoType = PhotoBrowserTypeDelete;
        photoBrowserController.currentPageIndex = row;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoBrowserController];
        [self presentViewController:nav animated:YES completion:nil];
    };
    return cell;
}

#pragma mark - PhotoBrowserDelegate
- (NSUInteger)numberOfSelectedPhotosInPhotoBrowser:(PhotoBrowserViewController *)photoBrowser {
    return _assetLibraryController.assetManager.selectedArray.count;
}

- (PhotoAssetModel*)photoBrowser:(PhotoBrowserViewController *)photoBrowser selectedPhotoAtIndex:(NSUInteger)index {
    
    PhotoAssetModel *photoModel = _assetLibraryController.assetManager.selectedArray[index];
    return photoModel;
}

- (void)photoBrowser:(PhotoBrowserViewController *)photoBrowser cancelSelectedPhoto:(PhotoAssetModel *)photoModel {
    
    [_assetLibraryController.assetManager deleteObjFromSelectedArrayWith:photoModel];
    [_assetLibraryController.assetManager deleteObjFromGroupPhotoArrayWith:photoModel];
    [_assetLibraryController updateDataSource];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - event response
- (void)cancelBtnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendRecord {
    
    if (_isQuickSignIn) {
        [self.view endEditing:YES];
        
        if (!_curRecord.relationCustomerId) {
            kTipAlert(@"请关联客户");
            return;
        }
        
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Common_SendRecord_WithPath:kNetPath_Customer_SendRecord obj:_curRecord block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                if (error.code == STATUS_SESSION_UNAVAILABLE) {
                    CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                    comRequest.RequestAgainBlock = ^(){
                        [self sendRecord];
                    };
                    [comRequest loginInBackground];
                }
            };
        }];
        return;
    }
    
    if (self.sendNextRecord) {
        self.sendNextRecord(_curRecord);
    }
    
    [self.view endEditing:YES];
    [_footToolBar removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)takePhotoButtonPress {
    
    if (![Helper checkCameraAuthorizationStatus]) {
        return;
    }else if (_curRecord.recordImages.count >= 9) {
        kTipAlert(@"最多只可选择9张照片，已经选满了。先去掉一张照片再拍照呗～");
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;//设置可编辑
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];//进入照相界面
}

- (void)photoButtonPress {
    
    [self inputViewResignFirstResponder];
    
    if (![Helper checkPhotoLibraryAuthorizationStatus]) {
        return;
    }
    
    @weakify(self);
    self.assetLibraryController.confirmBtnClickedBlock = ^(NSArray *array) {
        @strongify(self);
        self.curRecord.recordImages = [[NSMutableArray alloc] initWithArray:array];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.assetLibraryController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)atButtonPress {
    
    [self inputViewResignFirstResponder];
    
    __weak typeof(self) weak_self = self;
    ExportAddressViewController *exportController = [[ExportAddressViewController alloc] init];
    exportController.title = @"通讯录";
    exportController.valueBlock = ^(NSArray *array) {
        for (int i = 0; i < array.count; i ++) {
            AddressBook *tempBook = array[i];
            if (i == 0 && !weak_self.curRecord.recordStaffIds && !weak_self.curRecord.recordStaffIds.length) {
                weak_self.curRecord.recordStaffIds = [NSString stringWithFormat:@"%@", tempBook.id];
            }else {
                weak_self.curRecord.recordStaffIds = [NSString stringWithFormat:@"%@,%@", weak_self.curRecord.recordStaffIds, tempBook.id];
            }
            weak_self.curRecord.recordContent = [NSString stringWithFormat:@"%@@%@ ", weak_self.curRecord.recordContent, tempBook.name];
        }
        [weak_self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    };
    [self.navigationController pushViewController:exportController animated:YES];
}

- (void)voiceButtonPress {

    if (_inputState == InputStateSystem) {
        
        if ([self inputViewIsFirstResponder]) {
            _inputState = InputStateVoice;
            [self inputViewResignFirstResponder];
        }else {
            _inputState = InputStateVoice;
            [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
                [_footToolBar setY:kScreen_Height - CGRectGetHeight(_voiceView.bounds) - CGRectGetHeight(_footToolBar.bounds)];
                [_voiceView setY:kScreen_Height - CGRectGetHeight(_voiceView.bounds)];
            } completion:^(BOOL finished) {
            }];
        }
    }
}

- (void)locationButtonPress {
    MapViewViewController *controller = [[MapViewViewController alloc] init];
    controller.typeOfMap = @"location";
    controller.LocationResultBlock = ^(CLLocationCoordinate2D locCoordinate,NSString *location){
        
        _curRecord.position = location;
        _curRecord.latitude = [NSString stringWithFormat:@"%f", locCoordinate.latitude];
        _curRecord.longitude = [NSString stringWithFormat:@"%f", locCoordinate.longitude];
        
        [self configLocation];
        
        if (_isQuickSignIn) {
            [self configRelationCustomer];
        }
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)relationCustomerButtonPress {
    ContactNewSearchViewController *contactSearchController = [[ContactNewSearchViewController alloc] init];
    contactSearchController.selectedBlock = ^(Customer *item) {
        _curRecord.relationCustomerName = item.name;
        _curRecord.relationCustomerId = item.id;
        [self configRelationCustomer];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:contactSearchController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)deleteButtonPress {
    _curRecord.position = nil;
    _curRecord.latitude = nil;
    _curRecord.longitude = nil;
    
    [self configLocation];
}

- (BOOL)isEmptyRecord {
    BOOL isEmptyRecord = YES;
    if (_curRecord.recordContent && ![_curRecord.recordContent isEmpty]) {
        isEmptyRecord = NO;
    }
    return isEmptyRecord;
}

- (UIButton*)toolButtonWithIndex:(NSInteger)index imageStr:(NSString*)imageStr andAction:(SEL)sel {
    UIImage *image = [UIImage imageNamed:imageStr];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setWidth:64];
    [button setHeight:44];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
    UIImageWriteToSavedPhotosAlbum(originalImage, self, selectorToCall, NULL);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        @weakify(self);
        self.assetLibraryController.confirmBtnClickedBlock = ^(NSArray *array) {
            @strongify(self);
            self.curRecord.recordImages = [[NSMutableArray alloc] initWithArray:array];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        };
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.assetLibraryController];
        [self presentViewController:nav animated:YES completion:^{
            // 自动添加拍照图片
            [_assetLibraryController autoAddCameraPhoto];
        }];
    } else {
        NSLog(@"An error happened while saving the image.");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[RecordSendTextCell class] forCellReuseIdentifier:kCellIdentifier_text];
        [_tableView registerClass:[RecordSendImagesCell class] forCellReuseIdentifier:kCellIdentifier_images];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (UIView*)footToolBar {
    if (!_footToolBar) {
        _footToolBar = [[UIView alloc] init];
        [_footToolBar setY:kScreen_Height - 80];
        [_footToolBar setWidth:kScreen_Width];
        [_footToolBar setHeight:80];
        _footToolBar.backgroundColor = [UIColor whiteColor];
        
        [_footToolBar addSubview:self.locationButton];
        if (_isQuickSignIn) {
            [_footToolBar addSubview:self.relationCustomerButton];
        }
        [_footToolBar addSubview:self.toolBar];
        [_footToolBar addSubview:self.deleteLocationButton];
    }
    return _footToolBar;
}

- (UIView*)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIView alloc] init];
        [_toolBar setY:CGRectGetHeight(_footToolBar.bounds) - 44];
        [_toolBar setWidth:kScreen_Width];
        [_toolBar setHeight:44];
        [_toolBar addLineUp:YES andDown:NO andColor:[UIColor colorWithHexString:@"0xc8c7cc"]];
        _toolBar.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        
        UIButton *takePhotoButton = [self toolButtonWithIndex:0 imageStr:@"activity_take_photo" andAction:@selector(takePhotoButtonPress)];
        UIButton *photoButton = [self toolButtonWithIndex:1 imageStr:@"activity_img" andAction:@selector(photoButtonPress)];
        [photoButton setX:CGRectGetMaxX(takePhotoButton.frame)];
        UIButton *atButton = [self toolButtonWithIndex:2 imageStr:@"activity_at" andAction:@selector(atButtonPress)];
        [atButton setX:CGRectGetMaxX(photoButton.frame)];
        UIButton *voiceButton = [self toolButtonWithIndex:3 imageStr:@"acitvity_voice" andAction:@selector(voiceButtonPress)];
        [voiceButton setX:CGRectGetMaxX(atButton.frame)];
        [_toolBar addSubview:takePhotoButton];
        [_toolBar addSubview:photoButton];
        [_toolBar addSubview:atButton];
        [_toolBar addSubview:voiceButton];
    }
    return _toolBar;
}

- (UIButton*)locationButton {
    if (!_locationButton) {
        _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locationButton setX:5];
        [_locationButton setWidth:10];
        [_locationButton setHeight:30];
        [_locationButton setCenterY:36 / 2];
        _locationButton.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        _locationButton.layer.cornerRadius = CGRectGetHeight(_locationButton.bounds) / 2;
        _locationButton.clipsToBounds = YES;
        [_locationButton addTarget:self action:@selector(locationButtonPress) forControlEvents:UIControlEventTouchUpInside];
        
        [_locationButton addSubview:self.locationIcon];
        [_locationButton addSubview:self.locationTitle];
    }
    return _locationButton;
}

- (UIImageView*)locationIcon {
    if (!_locationIcon) {
        UIImage *image = [UIImage imageNamed:@"acitvity_position"];
        _locationIcon = [[UIImageView alloc] init];
        [_locationIcon setX:CGRectGetHeight(_locationButton.bounds) / 2];
        [_locationIcon setWidth:image.size.width];
        [_locationIcon setHeight:image.size.height];
        [_locationIcon setCenterY:CGRectGetHeight(_locationButton.bounds) / 2];
    }
    return _locationIcon;
}

- (UILabel*)locationTitle {
    if (!_locationTitle) {
        _locationTitle = [[UILabel alloc] init];
        [_locationTitle setX:CGRectGetMaxX(_locationIcon.frame) + 5];
        [_locationTitle setHeight:20];
        [_locationTitle setCenterY:CGRectGetHeight(_locationButton.bounds) / 2];
        _locationTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        _locationTitle.textAlignment = NSTextAlignmentLeft;
    }
    return _locationTitle;
}

- (UIButton*)deleteLocationButton {
    if (!_deleteLocationButton) {
        UIImage *image = [UIImage imageNamed:@"lbs_delete"];
        _deleteLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteLocationButton setWidth:CGRectGetHeight(_locationButton.bounds)];
        [_deleteLocationButton setHeight:CGRectGetHeight(_locationButton.bounds)];
        [_deleteLocationButton setCenterY:CGRectGetMidY(_locationButton.frame)];
        [_deleteLocationButton setImage:image forState:UIControlStateNormal];
        [_deleteLocationButton addTarget:self action:@selector(deleteButtonPress) forControlEvents:UIControlEventTouchUpInside];
        _deleteLocationButton.hidden = YES;
    }
    return _deleteLocationButton;
}

- (UIButton*)relationCustomerButton {
    if (!_relationCustomerButton) {
        
        _relationCustomerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_relationCustomerButton setWidth:10];
        [_relationCustomerButton setHeight:30];
        [_relationCustomerButton setCenterY:CGRectGetMidY(_locationButton.frame)];
        _relationCustomerButton.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        _relationCustomerButton.layer.cornerRadius = CGRectGetHeight(_relationCustomerButton.bounds) / 2;
        _relationCustomerButton.clipsToBounds = YES;
        [_relationCustomerButton addTarget:self action:@selector(relationCustomerButtonPress) forControlEvents:UIControlEventTouchUpInside];
        
        [_relationCustomerButton addSubview:self.relationCustomerIcon];
        [_relationCustomerButton addSubview:self.relationCustomerTitle];
    }
    return _relationCustomerButton;
}

- (UIImageView*)relationCustomerIcon {
    if (!_relationCustomerIcon) {
        UIImage *image = [UIImage imageNamed:@"account_icon_mini_normal"];
        _relationCustomerIcon = [[UIImageView alloc] initWithImage:image];
        [_relationCustomerIcon setX:CGRectGetHeight(_relationCustomerButton.bounds) / 2.0];
        [_relationCustomerIcon setWidth:image.size.width];
        [_relationCustomerIcon setHeight:image.size.height];
        [_relationCustomerIcon setCenterY:CGRectGetHeight(_relationCustomerButton.bounds) / 2.0];
    }
    return _relationCustomerIcon;
}

- (UILabel*)relationCustomerTitle {
    if (!_relationCustomerTitle) {
        _relationCustomerTitle = [[UILabel alloc] init];
        [_relationCustomerTitle setX:CGRectGetMaxX(_relationCustomerIcon.frame) + 5];
        [_relationCustomerTitle setHeight:20];
        [_relationCustomerTitle setCenterY:CGRectGetHeight(_relationCustomerButton.bounds) / 2.0];
        _relationCustomerTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        _relationCustomerTitle.textAlignment = NSTextAlignmentLeft;
    }
    return _relationCustomerTitle;
}

- (RecordSendVoiceView*)voiceView {
    if (!_voiceView) {
        _voiceView = [[RecordSendVoiceView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kKeyboardView_Height)];
    }
    return _voiceView;
}

- (PhotoAssetLibraryViewController*)assetLibraryController {
    if (!_assetLibraryController) {
        _assetLibraryController = [[PhotoAssetLibraryViewController alloc] init];
        _assetLibraryController.maxCount = 9;
    }
    return _assetLibraryController;
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
