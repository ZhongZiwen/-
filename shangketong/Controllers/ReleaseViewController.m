//
//  ReleaseViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ReleaseViewController.h"
#import "UIView+Common.h"
#import "NSString+Common.h"
#import <POP.h>
#import <TPKeyboardAvoidingScrollView.h>
#import <XLFormTextView.h>
#import "UITapImageView.h"
#import "ReleaseToolView.h"
#import "MapViewController.h"
#import "ReleasePrivacyController.h"
#import "ReleasePrivacyItem.h"
#import "PhotoAssetLibraryViewController.h"
#import "PhotoBrowserViewController.h"
#import "PhotoAssetManager.h"
#import "PhotoAssetModel.h"
#import "MapViewViewController.h"
#import "ExportAddressViewController.h"
#import "AddressBook.h"
#import "CommonFuntion.h"
#import "AFNHttp.h"
#import "CommonConstant.h"
#import <MBProgressHUD.h>
#import "AFHTTPRequestOperationManager.h"
#import "ForwardToolView.h"
#import "UIImageView+WebCache.h"
#import "FMDB_SKT_CACHE.h"
#import "CommonMsgStatusBar.h"
#import "WorkGroupRecordViewController.h"
#import "Record.h"
#import "Helper.h"

@interface ReleaseViewController ()<UITextViewDelegate, UIScrollViewDelegate, PhotoBrowserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
}

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, strong) XLFormTextView *textView;
@property (nonatomic, strong) UIView *imageBGView;
@property (nonatomic, strong) ReleaseToolView *toolView;
@property (nonatomic, copy) NSString *privacyStr;
@property (nonatomic, assign) NSInteger privacyIndex;
@property (nonatomic, assign) long long privacySelectedId;
@property (nonatomic, strong) PhotoAssetLibraryViewController *assetLibraryController;
@property (nonatomic, strong) ForwardToolView *forwardToolView;
@property (nonatomic, strong) UIView *forwardView;

@property (nonatomic, strong)  NSString *pathFile;
@property (nonatomic, strong)  NSString *nameFile;

/** 添加图片*/
- (void)addPhoto;

/** 将选中照片进行排版*/
- (void)addPhotoImageView;

/** 添加动画*/
- (POPSpringAnimation*)popAnimation;

@end

@implementation ReleaseViewController

#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    _latitude = 0;
    _longitude = 0;
    if (self.typeOfOptionDynamic == TypeOfOptionDynamicCRMRecord) {
        _privacyStr = @"";
    }else{
        _privacyStr = @"公开";
    }
    
    
    _privacyIndex = 0;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPhotoImageView) name:kAddPhotoImageViewNotification object:nil];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.view addSubview:self.scrollView];
    [_scrollView addSubview:self.textView];
    
    if (self.typeOfOptionDynamic == TypeOfOptionDynamicRelease) {
        [_scrollView addSubview:self.imageBGView];
        [self.view addSubview:self.toolView];
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicForward){
        [self.view addSubview:self.forwardToolView];
        [_scrollView addSubview:self.forwardView];
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicCRMRecord){
        [_scrollView addSubview:self.imageBGView];
        [self.view addSubview:self.toolView];
    }
    
    
    __weak __block typeof(self) weak_self = self;
    _toolView.locationBlock = ^{
        
        //        MapViewController *mapController = [[MapViewController alloc] init];
        //        mapController.title = @"地图";
        //        [weak_self.navigationController pushViewController:mapController animated:YES];
        [weak_self gotoMapView];
    };
    ///工作圈发布
    if ([self.typeOfRelease isEqualToString:@"zone"]) {
        _toolView.privateBlock = ^{
            ReleasePrivacyController *privacyController = [[ReleasePrivacyController alloc] init];
            privacyController.title = @"选择发布范围";
            privacyController.privacyItem = [ReleasePrivacyItem initWithIndex:weak_self.privacyIndex andTitle:weak_self.privacyStr];
            privacyController.selectRowBlock = ^(ReleasePrivacyItem *item) {
                weak_self.privacyIndex = item.indexRow;
                weak_self.privacyStr = item.privacyString;
                weak_self.privacySelectedId = item.selectedId;
            };
            [weak_self.navigationController pushViewController:privacyController animated:YES];
        };
    }else{
        ///群组或部门
        self.privacyStr = self.titleStr;
        self.privacySelectedId = self.parentId;
    }
    
    _toolView.toolSelectedBlock = ^(NSInteger index) {
        if (index == 0) {
            
            if (![Helper checkCameraAuthorizationStatus]) {
                return;
            }else if (_assetLibraryController.assetManager.selectedArray.count >= 9) {
                kTipAlert(@"最多只可选择9张照片，已经选满了。先去掉一张照片再拍照呗～");
                return;
            }
            
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.delegate = weak_self;
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [weak_self presentViewController:pickerController animated:YES completion:nil]; //进入照相界面
        }
        ///选取图片
        if (index == 1) {
            [weak_self addPhoto];
        }
        
        ///@同事
        if (index == 2) {
            [weak_self gotoAtView];
        }
        
        ///语音
        if (index == 3) {
            NSLog(@"语音");
            [weak_self setHideOrShowForVoiceView];
        }
    };
    
    ///录音文件
    _toolView.RecordingBlock = ^(NSString *path,NSString *name){
        NSLog(@"Release录音文件路径:%@",path);
        NSLog(@"Release录音文件名:%@",name);
        
        weak_self.pathFile = path;
        weak_self.nameFile = name;
    };
    
    ///转发
    
    _forwardToolView.privateBlock = ^{
        ReleasePrivacyController *privacyController = [[ReleasePrivacyController alloc] init];
        privacyController.title = @"选择发布范围";
        privacyController.privacyItem = [ReleasePrivacyItem initWithIndex:weak_self.privacyIndex andTitle:weak_self.privacyStr];
        privacyController.selectRowBlock = ^(ReleasePrivacyItem *item) {
            weak_self.privacyIndex = item.indexRow;
            NSLog(@"_forwardToolView  privacyStr3:%@",item.privacyString);
            weak_self.privacyStr = item.privacyString;
            weak_self.privacySelectedId = item.selectedId;
        };
        [weak_self.navigationController pushViewController:privacyController animated:YES];
    };
    
    _forwardToolView.atBlock = ^{
        [weak_self gotoAtView];
    };
    
    
    [_textView becomeFirstResponder];
}

- (void)dealloc {
    _scrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

///发布按钮
-(void)addRightBarBtn{
    
}

-(void)setHideOrShowForVoiceView{
    ///CRM-详情记录
    if (self.typeOfOptionDynamic == TypeOfOptionDynamicCRMRecord){
        [_textView resignFirstResponder];
        [_toolView notifyVoiceView];
        _toolView.frame = CGRectMake(0, kScreen_Height-89-216, kScreen_Width, 89+216);
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addObserverOfKeyBoard];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObserverOfKeyBoard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 定位页面
-(void)gotoMapView{
    __weak __block typeof(self) weak_self = self;
    MapViewViewController *controller = [[MapViewViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.typeOfMap = @"location";
    
    ///定位结果
    controller.LocationResultBlock = ^(CLLocationCoordinate2D locCoordinate,NSString *location){
        NSLog(@"latitude:%f  longitude:%f",locCoordinate.latitude,locCoordinate.longitude);
        NSLog(@"location:%@",location);
        weak_self.locationStr = location;
        weak_self.latitude = locCoordinate.latitude;
        weak_self.longitude = locCoordinate.longitude;
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - @同事页面
-(void)gotoAtView {
    @weakify(self);
    ExportAddressViewController *exportAddressController = [[ExportAddressViewController alloc] init];
    exportAddressController.title = @"选择同事";
    exportAddressController.valueBlock = ^(NSArray *array) {
        @strongify(self);
        [self initSelectContactNameStr:array];
    };
    [self.navigationController pushViewController:exportAddressController animated:YES];
}


#pragma mark - 通讯录选择同事
-(void)initSelectContactNameStr:(NSArray *)selectedContact{
    NSMutableString *nameAt = [[NSMutableString alloc] initWithString:@""];
    NSInteger count = 0;
    if (selectedContact) {
        count = [selectedContact count];
    }
    
    for (int i=0; i<count; i++) {
        AddressBook *model = selectedContact[i];
        [nameAt appendString:[NSString stringWithFormat:@" @%@ ",model.name]];
    }
    
    NSLog(@"nameAt:%@",nameAt);
    
    _textView.text = [NSString stringWithFormat:@"%@%@",_textView.text,nameAt];
    
    if (count > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}



#pragma mark - private method
- (void)addPhoto {
    __weak typeof(self) weak_self = self;
    self.assetLibraryController.confirmBtnClickedBlock = ^(NSArray *array) {
        [weak_self addPhotoImageView];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.assetLibraryController];
    [self presentViewController:nav animated:YES completion:^{
    }];
}

- (void)addPhotoImageView {
    
    for (UIView *view in _imageBGView.subviews) {
        [view removeFromSuperview];
    }
    
    __weak typeof(self) weak_self = self;
    for (int i = 0; i < _assetLibraryController.assetManager.selectedArray.count; i ++) {
        PhotoAssetModel *model = _assetLibraryController.assetManager.selectedArray[i];
        UITapImageView *imageView = [[UITapImageView alloc] initWithFrame:CGRectMake(10 + (64 + 10) * (i % 4), (64 + 10) * (i / 4), 64, 64)];
        imageView.tag = 200 + i;
        
        imageView.image = [UIImage imageWithCGImage:model.asset.thumbnail];
        imageView.imageViewTapBlock = ^(NSInteger tag) {
            PhotoBrowserViewController *photoBrowserController = [[PhotoBrowserViewController alloc] initWithDelegate:weak_self];
            photoBrowserController.photoType = PhotoBrowserTypeDelete;
            photoBrowserController.currentPageIndex = tag - 200;
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoBrowserController];
            [weak_self presentViewController:nav animated:YES completion:nil];
        };
        [_imageBGView addSubview:imageView];
        [imageView.layer pop_addAnimation:[self popAnimation] forKey:@"scaleAnimation"];
    }
    
    if (_assetLibraryController.assetManager.selectedArray.count != 9) {
        UITapImageView *addImageView = [[UITapImageView alloc] initWithFrame:CGRectMake(10 + (64 + 10) * (_assetLibraryController.assetManager.selectedArray.count % 4), (64 + 10) * (_assetLibraryController.assetManager.selectedArray.count / 4), 64, 64)];
        addImageView.image = [UIImage imageNamed:@"multi_add"];
        addImageView.imageViewTapBlock = ^(NSInteger tag) {
            [weak_self addPhoto];
        };
        [_imageBGView addSubview:addImageView];
    }
}

- (POPSpringAnimation*)popAnimation {
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.2, 0.2)];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
    scaleAnimation.springBounciness = 8.f;
    scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
    };
    return scaleAnimation;
}

#pragma mark - event response
- (void)leftButtonPress {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 发布
- (void)rightButtonPress {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    NSArray *arrayAtId = nil;
    
    ///先读取缓存
    //    NSArray *arrayCache = [FMDB_SKT_CACHE select_AddressBook_AllData];
    NSArray *arrayCache = [[FMDBManagement sharedFMDBManager] getAddressBookDataSource];
    if (arrayCache) {
        arrayAtId = [CommonFuntion getAtUserIds:_textView.text atArray:arrayCache isAddressBookArray:TRUE];
    }
    
    NSLog(@"arrayAtId:%@",arrayAtId);
    
    if (self.typeOfOptionDynamic == TypeOfOptionDynamicRelease) {
        [self sendCmdToRelease:arrayAtId];
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicForward){
        [self sendCmdToForwarding:arrayAtId];
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicCRMRecord){
        ///CRM-详情 记录
        [self sendCurRecord];
    }
}

-(void)sendCmdToRelease:(NSArray *)atIds{
    
    
    
    ///files(图片),
    ///content(动态内容),
    ///staffIds(@人id集合,以“,”分隔开),
    ///warnType(部门或者群组类型,必传,默认传入1), 群组1001 部门1002
    ///warnId(部门或者群组ID),
    /// Long longitude, Long latitude, String position
    NSString *content = _textView.text;
    
    if (content.length > 300) {
        [CommonFuntion showToast:@"动态内容长度最大为300字" inView:self.view];
    }
    
    NSString *staffIds = [CommonFuntion getStringStaffIds:atIds];
    
    NSLog(@"content:%@",content);
    NSLog(@"staffIds:%@",staffIds);
    NSLog(@"privacyStr:%@   privacyIndex:%ti  privacySelectedId:%lld",_privacyStr,_privacyIndex,_privacySelectedId);
    
    if (atIds && atIds.count > 9) {
        kShowHUD(@"你最多能@9人");
        return;
    }
    
    NSInteger warnType = 1;
    
    ///工作圈
    if ([self.typeOfRelease isEqualToString:@"zone"]) {
        if (_privacyIndex == 1) {
            warnType = 1002;
        }else if (_privacyIndex == 2){
            warnType = 1001;
        }
    }else{
        ///部门
        if ([self.typeOfRelease isEqualToString:@"department"]) {
            warnType = 1002;
        }else{
            warnType = 1001;
        }
    }
    
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    [params setObject:content forKey:@"content"];
    
    [params setObject:[NSNumber numberWithInteger:warnType] forKey:@"warnType"];
    if (warnType != 1) {
        [params setObject:[NSNumber numberWithLongLong:_privacySelectedId] forKey:@"warnId"];
    }
    ///（@人id集合,以“,”分隔开）
    [params setObject:staffIds forKey:@"staffIds"];
    
    if (_latitude != 0 && _longitude != 0) {
        [params setObject:[NSNumber numberWithFloat:_latitude] forKey:@"latitude"];
        [params setObject:[NSNumber numberWithFloat:_longitude] forKey:@"longitude"];
        [params setObject:_locationStr forKey:@"position"];
    }
    
    NSLog(@"params:%@",params);
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript",@"text/plain", nil];
    manager.requestSerializer.timeoutInterval = 15;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,TREND_ADD_A_DYNAMIC] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for (int i = 0; i < _assetLibraryController.assetManager.selectedArray.count; i ++) {
            PhotoAssetModel *model = _assetLibraryController.assetManager.selectedArray[i];
            
            NSString *imgName = [CommonFuntion getFileNameDeleteEctension:[[model.asset defaultRepresentation] filename]];
            //            NSLog(@"imgName:%@",imgName);
            
            
            CGImageRef ref = [[model.asset  defaultRepresentation]fullScreenImage];
            UIImage *img = [[UIImage alloc]initWithCGImage:ref];
            
            
            NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
            NSLog(@"imageData size jpeg:%lu",imageData.length/1024);
            
            if ((float)imageData.length/1024 > 1000) {
                float quality = 1024*1000.0/(float)(imageData.length);
                NSLog(@"imageData quality:%f",quality/3);
                imageData = UIImageJPEGRepresentation(img, quality/3);
            }else{
                NSLog(@"imageData quality:0.5");
                imageData = UIImageJPEGRepresentation(img, 0.5);
            }
            NSLog(@"imageData size new:%lu",imageData.length/1024);
            
            NSLog(@"============================");
            
            [formData appendPartWithFileData :imageData name:@"files" fileName:[NSString stringWithFormat:@"%@.jpeg",imgName] mimeType:@"image/jpeg"];
        }
        
    } success:^(AFHTTPRequestOperation *operation,id responseObject) {
        [hud hide:YES];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSLog(@"发布动态 responseObj:%@",responseObject);
        if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == 0) {
            //            CommonMsgStatusBar *statusView = [[CommonMsgStatusBar alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
            //            [statusView showStatusMessage:@"发送成功"];
            
            [NSObject showStatusBarSuccessStr:@"发布成功"];
            if (self.ReleaseSuccessNotifyData) {
                self.ReleaseSuccessNotifyData();
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }else if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self sendCmdToRelease:atIds];
            };
            [comRequest loginInBackground];
        }
        else{
            [CommonFuntion showToast:@"发布失败" inView:self.view];
        }
        NSLog(@"desc:%@",[responseObject safeObjectForKey:@"desc"]);
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [hud hide:YES];
        [CommonFuntion showToast:@"发布失败" inView:self.view];
        NSLog ( @"operation: %@" , operation. responseString );
        NSLog(@"error:%@",error);
        
    }];
}

- (void)sendCurRecord {
    Record *record = [Record initRecordForSend];
    record.recordId = _recordId;
    record.recordAudioFile = [NSString stringWithFormat:@"%@/%@", _pathFile, _nameFile];
    record.recordAudioSecond = [NSNumber numberWithInteger:4 * 1000];
    [[Net_APIManager sharedManager] request_Common_SendRecord_WithPath:kNetPath_Activity_SendRecord obj:record block:^(id data, NSError *error) {
        if (data) {
            
        }
    }];
}

#pragma mark - 转发动态
-(void)sendCmdToForwarding:(NSArray *)atIds{
    ///参数：trendsId(动态ID),content(转发理由),staffIds(@人id集合,以“,”分隔开),warnType(部门或者群组类型,必传,默认传入1),warnId(部门或者群组ID)
    
    
    NSString *content = _textView.text;
    if (content.length > 300) {
        [CommonFuntion showToast:@"动态内容最大为300字" inView:self.view];
        return;
    }
    NSString *staffIds = [CommonFuntion getStringStaffIds:atIds];
    
    NSLog(@"content:%@",content);
    NSLog(@"staffIds:%@",staffIds);
    NSLog(@"privacyStr:%@   privacyIndex:%ti  privacySelectedId:%lld",_privacyStr,_privacyIndex,_privacySelectedId);
    
    if (atIds && atIds.count > 9) {
        kShowHUD(@"你最多能@9人");
        return;
    }
    
    NSInteger warnType = 1;
    if (_privacyIndex == 1) {
        warnType = 1002;
    }else if (_privacyIndex == 2){
        warnType = 1001;
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    
    ///动态id
    long long trendsId = -1;
    if ([self.itemDynamic objectForKey:@"id"]) {
        trendsId = [[self.itemDynamic safeObjectForKey:@"id"] longLongValue];
    }
    [params setObject:[NSNumber numberWithLongLong:trendsId] forKey:@"trendsId"];
    
    [params setObject:content forKey:@"content"];
    
    [params setObject:[NSNumber numberWithInteger:warnType] forKey:@"warnType"];
    if (warnType != 1) {
        [params setObject:[NSNumber numberWithLongLong:_privacySelectedId] forKey:@"warnId"];
    }
    ///（@人id集合,以“,”分隔开）
    [params setObject:staffIds forKey:@"staffIds"];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSLog(@"params:%@",params);
    __weak typeof(self) weak_self = self;
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,TREND_FORWARD_A_DYNAMIC] params:params success:^(id responseObject) {
        [hud hide:YES];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        //字典转模型
        NSLog(@"转发动态 responseObj:%@",responseObject);
        if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == 0) {
            CommonMsgStatusBar *statusView = [[CommonMsgStatusBar alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
            [statusView showStatusMessage:@"发送成功"];
            if (weak_self.ReleaseSuccessNotifyData) {
                weak_self.ReleaseSuccessNotifyData();
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == 2){
            NSString *desc = [responseObject safeObjectForKey:@"desc"];
            kShowHUD(desc,nil);
            if (weak_self.ReleaseSuccessNotifyData) {
                weak_self.ReleaseSuccessNotifyData();
            }
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[WorkGroupRecordViewController class]]) {
                    [weak_self.navigationController popToViewController:controller animated:YES];
                }
            }
        } else if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self sendCmdToForwarding:atIds];
            };
            [comRequest loginInBackground];
        }
        else{
            [CommonFuntion showToast:@"转发失败" inView:weak_self.view];
        }
        NSLog(@"desc:%@",[responseObject safeObjectForKey:@"desc"]);
    } failure:^(NSError *error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSLog(@"error:%@",error);
        [hud hide:YES];
    }];
    
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
    
    [self addPhotoImageView];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
    UIImageWriteToSavedPhotosAlbum(originalImage, self, selectorToCall, NULL);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        __weak typeof(self) weak_self = self;
        self.assetLibraryController.confirmBtnClickedBlock = ^(NSArray *array) {
            [weak_self addPhotoImageView];
        };
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.assetLibraryController];
        [self presentViewController:nav animated:YES completion:^{
            // 自动添加拍照图片
            [_assetLibraryController autoAddCameraPhoto];
        }];
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    // 限制textView字数
    UITextRange *selectedRange = [textView markedTextRange];
    // 获取高亮部分
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    
    // 如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && position) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < MAX_LIMIT_TEXTVIEW) {
            return YES;
        }
        else {
            return NO;
        }
    }
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = MAX_LIMIT_TEXTVIEW - comcatstr.length;
    
    if (caninputlen >= 0) {
        return YES;
    }
    else {
        NSInteger len = text.length + caninputlen;
        // 防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = [text substringWithRange:rg];
            
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    
    if (textView.text && ![CommonFuntion isEmptyString:textView.text]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    if (textView.contentSize.height > 110.f) {
        //        [_textView setHeight:textView.contentSize.height];
        //        [_imageBGView setY:_textView.frame.origin.y + textView.contentSize.height + 10];
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_LIMIT_TEXTVIEW)
    {
        //截取到最大位置的字符
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_TEXTVIEW];
        
        [textView setText:s];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_textView resignFirstResponder];
}

#pragma mark - setters and getters
- (void)setLocationStr:(NSString *)locationStr {
    if ([_locationStr isEqualToString:locationStr])
        return;
    
    _locationStr = locationStr;
    
    _toolView.locationBtnTitle = _locationStr;
}

- (void)setPrivacyStr:(NSString *)privacyStr {
    if ([_privacyStr isEqualToString:privacyStr])
        return;
    if (privacyStr == nil) {
        privacyStr = @"公开";
        _privacyIndex = 0;
    }
    _privacyStr = privacyStr;
    
    if (self.typeOfOptionDynamic == TypeOfOptionDynamicRelease) {
        _toolView.privateBtnTitle = _privacyStr;
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicForward){
        NSLog(@"forwardToolView _privacyStr2:%@",_privacyStr);
        _forwardToolView.privateBtnTitle = _privacyStr;
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicCRMRecord){
        _toolView.privateBtnTitle =@"";
    }
    
}

- (TPKeyboardAvoidingScrollView*)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:kScreen_Bounds];
        _scrollView.contentSize = CGSizeMake(kScreen_Width, kScreen_Height - 64 + 0.5);
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (XLFormTextView*)textView {
    if (!_textView) {
        CGFloat height = 0;
        if (self.typeOfOptionDynamic == TypeOfOptionDynamicRelease) {
            height = 150.0f;
        }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicForward){
            height = 110.0f;
        }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicCRMRecord){
            height = 110.0f;
        }
        _textView = [[XLFormTextView alloc] initWithFrame:CGRectMake(10, 10, kScreen_Width - 20, height)];
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.delegate = self;
        if (self.typeOfOptionDynamic == TypeOfOptionDynamicRelease) {
            _textView.placeholder = @"来，冒个泡吧...";
        }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicForward){
            _textView.placeholder = @"请输入转发理由...";
        }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicCRMRecord){
            _textView.placeholder = @"嘿，冒个泡吧...";
        }
        _textView.layoutManager.allowsNonContiguousLayout = YES;
        _textView.returnKeyType = UIReturnKeyDefault;
        _textView.backgroundColor = [UIColor whiteColor];
    }
    return _textView;
}

- (UIView*)imageBGView {
    if (!_imageBGView) {
        _imageBGView = [[UIView alloc] initWithFrame:CGRectMake(0, _textView.frame.origin.y + CGRectGetHeight(_textView.bounds) + 10, kScreen_Width, 220)];
    }
    return _imageBGView;
}

- (ReleaseToolView*)toolView {
    if (!_toolView) {
        
        ///CRM-详情记录
        if (self.typeOfOptionDynamic == TypeOfOptionDynamicCRMRecord){
            _toolView = [[ReleaseToolView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 89, kScreen_Width, 89)];
            _toolView.privateBtnTitle = @"";
        }else{
            _toolView = [[ReleaseToolView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 88, kScreen_Width, 88)];
            _toolView.privateBtnTitle = _privacyStr;
        }
        _toolView.locationBtnTitle = _locationStr;
        
    }
    return _toolView;
}



- (PhotoAssetLibraryViewController*)assetLibraryController {
    if (!_assetLibraryController) {
        _assetLibraryController = [[PhotoAssetLibraryViewController alloc] init];
        _assetLibraryController.maxCount = 9;
    }
    return _assetLibraryController;
}


-(ForwardToolView*)forwardToolView{
    if (!_forwardToolView) {
        _forwardToolView = [[ForwardToolView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 44, kScreen_Width, 44)];
        NSLog(@"forwardToolView _privacyStr:%@",_privacyStr);
        _forwardToolView.privateBtnTitle = _privacyStr;
    }
    return _forwardToolView;
}


- (UIView*)forwardView {
    if (!_forwardView) {
        
        ///user
        NSDictionary *user = nil;
        if ([self.itemDynamic objectForKey:@"user"]) {
            user = [self.itemDynamic objectForKey:@"user"];
        }
        
        NSString *name = @"";
        NSString *icon = @"";
        if (user) {
            ///姓名
            if ([user objectForKey:@"name"]) {
                name = [user safeObjectForKey:@"name"];
            }
            ///头像
            if ([user objectForKey:@"icon"]) {
                icon = [user safeObjectForKey:@"icon"];
            }
        }
        
        
        NSDictionary *from = nil;
        if ([self.itemDynamic objectForKey:@"from"]) {
            from = [self.itemDynamic objectForKey:@"from"];
        }
        
        NSString *fromname = @"";
        if (from) {
            if ([from objectForKey:@"name"]) {
                fromname = [from safeObjectForKey:@"name"];
            }
        }
        
        
        ///content
        NSString *content = @"";
        if ([self.itemDynamic safeObjectForKey:@"content"]) {
            content = [NSString stringWithFormat:@"%@    ",[self.itemDynamic objectForKey:@"content"]];
        }
        
        
        _forwardView = [[UIView alloc] initWithFrame:CGRectMake(10, _textView.frame.origin.y + CGRectGetHeight(_textView.bounds) + 90, kScreen_Width-20, 60)];
        _forwardView.layer.borderColor = [UIColor colorWithRed:215.0f/255 green:215.0f/255 blue:215.0f/255 alpha:1.0f].CGColor;
        _forwardView.layer.borderWidth = 1;
        
        UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 40, 40)];
        [imgIcon sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:PLACEHOLDER_CONTACT_ICON]];
        [_forwardView addSubview:imgIcon];
        
        ///隐藏掉头像
        imgIcon.hidden = YES;
        
        CGSize sizeName = [CommonFuntion getSizeOfContents:name Font:[UIFont systemFontOfSize:14.0] withWidth:kScreen_Width-120 withHeight:20];
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, sizeName.width, 20)];
        labelName.font = [UIFont systemFontOfSize:14.0];
        labelName.text = name;
        [_forwardView addSubview:labelName];
        
        if (from && ![fromname isEqualToString:@""]) {
            
            UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(labelName.frame.origin.x+sizeName.width+2, 17, 4, 5)];
            arrow.image = [UIImage imageNamed:@"feed_ico_grouparrow.png"];
            
            UILabel *labelFromname = [[UILabel alloc] initWithFrame:CGRectMake(arrow.frame.origin.x+6, 10, kScreen_Width-sizeName.width-70, 20)];
            labelFromname.font = [UIFont systemFontOfSize:13.0];
            labelFromname.textColor = [UIColor grayColor];
            labelFromname.text = fromname;
            
            
            [_forwardView addSubview:arrow];
            [_forwardView addSubview:labelFromname];
        }
        
        
        UILabel *labelContent = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, kScreen_Width-40, 35)];
        labelContent.font = [UIFont systemFontOfSize:12.0];
        labelContent.numberOfLines = 0;
        labelContent.textAlignment = NSTextAlignmentLeft;
        labelContent.textColor = [UIColor grayColor];
        labelContent.text = content;
        [_forwardView addSubview:labelContent];
    }
    return _forwardView;
}




#pragma mark 添加键盘事件监听
-(void)addObserverOfKeyBoard{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)removeObserverOfKeyBoard{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
}


//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    NSLog(@"keyboard height:%f",keyboardBounds.size.height);
    
    _textView.frame = CGRectMake(10, 10, kScreen_Width - 20, kScreen_Height-keyboardBounds.size.height-89-64-15-30);
    _imageBGView.frame = CGRectMake(0, _textView.frame.origin.y + _textView.frame.size.height + 20, kScreen_Width, 220);
    
    NSLog(@"_textView.frame height:%f",_textView.frame.size.height);
    // get a rect for the textView frame
    CGRect containerFrame;
    
    
    if (self.typeOfOptionDynamic == TypeOfOptionDynamicRelease) {
        containerFrame = _toolView.frame;
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicForward){
        containerFrame = _forwardToolView.frame;
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicCRMRecord){
        _toolView.frame = CGRectMake(0, kScreen_Height-89, kScreen_Width, 89);
        containerFrame = _toolView.frame;
    }
    
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    if (self.typeOfOptionDynamic == TypeOfOptionDynamicRelease) {
        _toolView.frame = containerFrame;
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicForward){
        _forwardToolView.frame = containerFrame;
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicCRMRecord){
        _toolView.frame = containerFrame;
    }
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame ;
    if (self.typeOfOptionDynamic == TypeOfOptionDynamicRelease) {
        containerFrame = _toolView.frame;
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicForward){
        containerFrame = _forwardToolView.frame;
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicCRMRecord){
        containerFrame = _toolView.frame;
    }
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    if (self.typeOfOptionDynamic == TypeOfOptionDynamicRelease) {
        _toolView.frame = containerFrame;
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicForward){
        _forwardToolView.frame = containerFrame;
    }else if (self.typeOfOptionDynamic == TypeOfOptionDynamicCRMRecord){
        _toolView.frame = containerFrame;
    }
    // commit animations
    [UIView commitAnimations];
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
