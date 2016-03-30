//
//  FileListDetailController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FileListDetailController.h"
#import <QuickLook/QuickLook.h>
#import "FileListController.h"
#import "Directory.h"
#import "FileDownloadView.h"
#import "BasicPreviewItem.h"
#import "PopoverView.h"
#import "PopoverItem.h"

@interface FileListDetailController ()<QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) FileDownloadView *downloadView;

@property (strong, nonatomic) NSURL *fileUrl;
@property (strong, nonatomic) QLPreviewController *previewController;
@property (strong, nonatomic) UIWebView *contentWebView;

@end

@implementation FileListDetailController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    if (_isShowRightBarButton) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithIcon:@"menu_showMore" showBadge:NO target:self action:@selector(rightButtonPress)];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configContent {
    
    BOOL isExisted = [[FileManager sharedManager] isExistedForFileName:_directory.name];
    if (!isExisted) {
        [self showDownloadView];
    }
    else {
        _fileUrl = [[FileManager sharedManager] urlForDownloadFile:_directory.name];
        if ([_directory.fileType isEqualToString:@"html"] || [_directory.fileType isEqualToString:@"txt"] || [_directory.fileType isEqualToString:@"plist"]) {
            [self loadWebView:_fileUrl];
        }
        else if ([QLPreviewController canPreviewItem:_fileUrl]) {
            [self showDiskFile:_fileUrl];
        }
        else {
            [self showDownloadView];
        }
    }
}

- (void)showDownloadView {
    self.contentWebView.hidden = self.previewController.view.hidden = YES;
    if (!self.downloadView) {
        _downloadView = [[FileDownloadView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_downloadView];
    }

    _downloadView.directory = _directory;
    [_downloadView reloadData];
    
    @weakify(self);
    _downloadView.completeBlock = ^{
        @strongify(self);
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[FileListController class]]) {
                FileListController *fileListController = (FileListController*)controller;
                [fileListController refreshDataSource];
                break;
            }
        }
        [self configContent];
    };
    _downloadView.hidden = NO;
}

- (void)loadWebView:(NSURL*)fileUrl {
    self.downloadView.hidden = self.previewController.view.hidden = YES;
    
    if (!_contentWebView) {
        // 用webView显示内容
        _contentWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _contentWebView.delegate = self;
        _contentWebView.backgroundColor = [UIColor clearColor];
        _contentWebView.opaque = NO;
        _contentWebView.scalesPageToFit = YES;
        [self.view addSubview:_contentWebView];
    }
    
    if ([_directory.fileType isEqualToString:@"html"]) {
        NSString *htmlString = [NSString stringWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:nil];
        [_contentWebView loadHTMLString:htmlString baseURL:nil];
    }
    else if ([_directory.fileType isEqualToString:@"plist"] || [_directory.fileType isEqualToString:@"txt"]) {
        NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
        [_contentWebView loadData:fileData MIMEType:@"text/text" textEncodingName:@"UTF-8" baseURL:fileUrl];
    }
    else {
        [_contentWebView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
    }
    _contentWebView.hidden = NO;
}

- (void)showDiskFile:(NSURL*)fileUrl {
    self.downloadView.hidden = self.contentWebView.hidden = YES;
    
    if (!_previewController) {
        QLPreviewController *preview = [[QLPreviewController alloc] init];
        preview.dataSource = self;
        preview.delegate = self;
        [self.view addSubview:preview.view];
        [preview.view setY:64];
        [preview.view setWidth:kScreen_Width];
        [preview.view setHeight:kScreen_Height - 64];
        _previewController = preview;
    }
    _previewController.view.hidden = NO;
}

#pragma mark - event response
- (void)rightButtonPress {

    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];

    // 收藏&取消收藏
    PopoverItem *favoriteItem;
    if ([_directory.hasFavorite isEqualToNumber:@1]) {
        favoriteItem = [PopoverItem initItemWithTitle:@"收藏" image:nil target:self action:@selector(favoriteItemAction)];
    }
    else {
        favoriteItem = [PopoverItem initItemWithTitle:@"取消收藏" image:nil target:self action:@selector(favoriteItemAction)];
    }
    [tempArray addObject:favoriteItem];
    
    // 本地删除
    PopoverItem *localDeleteItem;
    if ([[FileManager sharedManager] isExistedForFileName:_directory.name]) {
        localDeleteItem = [PopoverItem initItemWithTitle:@"从本地删除" image:nil target:self action:@selector(localDeleteItemAction)];
    }
    if (localDeleteItem) {
        [tempArray addObject:localDeleteItem];
    }
    
    // 服务器删除
    PopoverItem *serviceDeleteItem;
    if ([appDelegateAccessor.moudle.userId isEqualToString:[NSString stringWithFormat:@"%@", _directory.creator.id]]) {
        serviceDeleteItem = [PopoverItem initItemWithTitle:@"从服务器删除" image:nil target:self action:@selector(serviceDeleteItemAction)];
    }
    if (serviceDeleteItem) {
        [tempArray addObject:serviceDeleteItem];
    }
    
    PopoverView *pop = [[PopoverView alloc] initWithImageItems:nil titleItems:tempArray];
    [pop show];
}

- (void)favoriteItemAction {
    NSString *path = [_directory.hasFavorite integerValue] ? kNetPath_Common_File_Favorite : kNetPath_Common_File_CancelFavorite;
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempParams setObject:_directory.resourceId forKey:@"id"];
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Common_File_WithPath:path params:tempParams block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            if ([_directory.hasFavorite isEqualToNumber:@0]) {
                [NSObject showStatusBarSuccessStr:@"取消收藏成功"];
                _directory.hasFavorite = @1;
            }
            else {
                [NSObject showStatusBarSuccessStr:@"收藏成功"];
                _directory.hasFavorite = @0;
            }
        }
        else if (error.code == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [self favoriteItemAction];
            };
            [comRequest loginInBackground];
        }
    }];
}

- (void)localDeleteItemAction {
    if ([[FileManager sharedManager] deleteFileWithName:_directory.name]) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[FileListController class]]) {
                FileListController *listController = (FileListController*)controller;
                [listController refreshDataSource];
                [self.navigationController popToViewController:listController animated:YES];
                break;
            }
        }
    }
}

- (void)serviceDeleteItemAction {
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempParams setObject:_directory.resourceId forKey:@"id"];
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Common_File_WithPath:kNetPath_Common_File_Delete params:tempParams block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[FileListController class]]) {
                    FileListController *fileListController = (FileListController*)controller;
                    [fileListController deleteDataSource];
                    [self.navigationController popToViewController:fileListController animated:YES];
                    break;
                }
            }
        }
        else if (error.code == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [self serviceDeleteItemAction];
            };
            [comRequest loginInBackground];
        }
    }];
}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    NSInteger num = 0;
    if (_fileUrl) {
        num = 1;
    }
    return num;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [BasicPreviewItem itemWithUrl:self.fileUrl];
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    DebugLog(@"strLink=[%@]",request.URL.absoluteString);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.view beginLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.view endLoading];
    if ([_directory.fileType isEqualToString:@"plist"] || [_directory.fileType isEqualToString:@"txt"]) {
        [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 3.0;"];
    }else if ([_directory.fileType isEqualToString:@"html"]){
//        [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 2.0;"];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
    else {
        DebugLog(@"%@", error.description);
        [NSObject showError:error];
    }
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
