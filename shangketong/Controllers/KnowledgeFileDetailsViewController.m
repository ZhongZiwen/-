//
//  KnowledgeFileDetailsViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-5-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "KnowledgeFileDetailsViewController.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "AFHTTPRequestOperationManager.h"
#import "DownLoadOperation.h"
#import <MBProgressHUD.h>
#import "AFNHttp.h"
#import "NSUserDefaults_Cache.h"
#import "CommonRequstFuntion.h"
#import "ReportToServiceViewController.h"

@interface KnowledgeFileDetailsViewController ()<UIActionSheetDelegate>{
    AFURLSessionManager *sessionManager;
    // http://www.blogjava.net/qileilove/archive/2014/12/11/421323.html
    DownLoadOperation* operation;
    NSString *filePath;
}

@end

@implementation KnowledgeFileDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kView_BG_Color;
    
    self.webView.scalesPageToFit = YES;

    if (_isNeedRightNavBtn) {
        [self addRightNarBtn];
    }
    [self initViewData];
    [self setCurViewFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.DismissSearchViewBlock) {
        self.DismissSearchViewBlock();
    }
}

#pragma mark - 初始化数据
-(void)initViewData{
    self.details = [[NSMutableDictionary alloc] initWithDictionary:self.detailsOld];
    
    ///知识库页面进入
    if ([self.viewFrom isEqualToString:@"knowledge"]) {
        NSLog(@"------知识库页面进入------>");
        NSInteger isDownloadAble = [[self.details safeObjectForKey:@"downloadAble"] integerValue];
        if ([[self.details safeObjectForKey:@"downloadAble"] isEqualToString:@""]) {
            isDownloadAble = 1;
        }
        if (isDownloadAble == 0) {
            self.btnPreview.enabled = YES;
        }else{
            self.btnPreview.enabled = NO;
            [self.btnPreview setTitle:@"无法预览" forState:UIControlStateNormal];
            [self.btnPreview  setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }else{
        ///其他页面进入 不做判断
        NSLog(@"------其他页面进入------>");
        self.btnPreview.enabled = YES;
    }
    
    /*
    NSInteger isDownloadAble = 1;
    if ([self.details objectForKey:@"downloadAble"]) {
        isDownloadAble = [[self.details objectForKey:@"downloadAble"] integerValue];
    }
    if (isDownloadAble == 0) {
        self.btnPreview.enabled = YES;
    }else{
        self.btnPreview.enabled = NO;
        [self.btnPreview setTitle:@"无法预览" forState:UIControlStateNormal];
        [self.btnPreview  setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
     */
    
    
    NSLog(@"self.details:%@",self.details);
    NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
    NSString *userId = [userInfo safeObjectForKey:@"id"] ;
    NSString *fileName = [NSString stringWithFormat:@"%@-%@-%@-%@",userId,[self.details safeObjectForKey:@"resourceId"],PATH_KNOWLEDGE_FILENAME_PREFIX,[self.details safeObjectForKey:@"name"]];
//    NSLog(@"fileName:%@",fileName);
    self.title = [self.details safeObjectForKey:@"name"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    filePath = [cachesDirectory stringByAppendingPathComponent:fileName];
    ///判断本地是否存在文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([self isCanPreviewFile]) {
        
    }
    
    if([fileManager fileExistsAtPath:filePath]){
                NSLog(@"文件存在--->");
        [self showViewWithWebView];
    }else{
                NSLog(@"文件不存在--->");
        [self showViewFileNotExist];
    }
}


///判断 如果是压缩文件  则不可预览
-(BOOL)isCanPreviewFile{
    ///rar,zip,tar,cab,uue,jar,iso,z,7-zip,ace,lzh,arj,gzip,bz2
    NSString *name =   [self.details safeObjectForKey:@"name"];
    ///txt文件
    if ([name hasSuffix:@".zip"] || [name hasSuffix:@".rar"] || [name hasSuffix:@".jar"] || [name hasSuffix:@".7-zip"]  || [name hasSuffix:@".tar"]  || [name hasSuffix:@".gzip"]  || [name hasSuffix:@".iso"]  || [name hasSuffix:@".cab"]  || [name hasSuffix:@".arj"]  || [name hasSuffix:@".bz2"]) {
        
        self.btnPreview.enabled = NO;
        [self.btnPreview setTitle:@"无法预览" forState:UIControlStateNormal];
        [self.btnPreview  setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        return FALSE;
    }
    return TRUE;
}

///预览
- (IBAction)actionPreview:(id)sender {
    self.btnPreview.hidden = YES;
    self.viewProgress.hidden = NO;
    [self.progressview setProgress:0 animated:NO];
    
     NSString *url = [self.details objectForKey:@"url"];
    [self downloadFile:url];
}

///取消
- (IBAction)actioinCancel:(id)sender {
    self.btnPreview.hidden = NO;
    self.viewProgress.hidden = YES;
    [self.progressview setProgress:0 animated:NO];
}


#pragma mark -文件存在或已下载完成  则直接显示
///文件存在或已下载完成  则直接显示
-(void)showViewWithWebView{
    NSLog(@"showViewWithWebView---：%@",filePath);
    self.imgIcon.hidden = YES;
    self.labelName.hidden = YES;
    self.labelSize.hidden = YES;
    self.viewProgress.hidden = YES;
    self.btnPreview.hidden = YES;
    self.webView.hidden = NO;
    
    ///txt文件
    if ([filePath hasSuffix:@".txt"]) {
        [self showTxtView];
    }else{
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    }
}

///显示txt文件  乱码问题
-(void)showTxtView{
    NSStringEncoding *useEncodeing = nil;
    //带编码头的如utf-8等，这里会识别出来
    NSString *body = [NSString stringWithContentsOfFile:filePath usedEncoding:useEncodeing error:nil];
    //识别不到，按GBK编码再解码一次.这里不能先按GB18030解码，否则会出现整个文档无换行bug。
    if (!body) {
        body = [NSString stringWithContentsOfFile:filePath encoding:0x80000632 error:nil];
    }
    //还是识别不到，按GB18030编码再解码一次.
    if (!body) {
        body = [NSString stringWithContentsOfFile:filePath encoding:0x80000631 error:nil];
    }
    
    //展现
    if (body) {
        [self.webView loadHTMLString:body baseURL: nil];
    }else {
        NSString *urlString = [[NSBundle mainBundle] pathForAuxiliaryExecutable:filePath];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *requestUrl = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
        [self.webView loadRequest:request];
    }
}


#pragma mark - 文件不存在 view
-(void)showViewFileNotExist{
    NSLog(@"--showViewFileNotExist-->");
    self.imgIcon.hidden = NO;
    self.labelName.hidden = NO;
    self.labelSize.hidden = NO;
    self.btnPreview.hidden = NO;
    
    self.webView.hidden = YES;
    self.viewProgress.hidden = YES;
    [self.progressview setProgress:0 animated:NO];
    
#warning size类型问题
    long long  size = 0;
    if ([self.details objectForKey:@"size"]) {
        size = [[self.details safeObjectForKey:@"size"] longLongValue];
    }
    
    NSString *strSize = [CommonFuntion byteConversionGBMBKB:size];
    self.labelSize.text = strSize;
    
    NSString *name = @"";
    if ([self.details objectForKey:@"name"]) {
        name = [self.details safeObjectForKey:@"name"];
    }
    self.labelName.text = name;
}

#pragma mark - 根据下载地址下载文件
-(void)downloadFile:(NSString *)url{
    AFHTTPRequestOperation *operation2 = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];

    //下载请求
    operation2.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    //下载进度条
    [operation2 setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        NSLog(@"显示下载进度--->");
        //显示下载进度
        float progress = totalBytesRead / (float)totalBytesExpectedToRead;
        
        [self.progressview setProgress:progress animated:YES];
        
    }];
    
    //请求结果
    [operation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //请求成功
        NSLog(@"下载成功--->");
        NSLog(@"Finish and Download to: %@", filePath);
        //        NSData *data = [NSData dataWithContentsOfFile:filePath options:0 error:NULL];
        //        NSLog(@"data:%@",data);
        
        [self showViewWithWebView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //请求失败
        NSLog(@"下载失败--->");
        NSLog(@"Error: %@",error);
        [CommonFuntion showToast:@"文件预览失败" inView:self.view];
        ///下载失败则清除掉路径
        [self removeFileByPath];
        
    }];
    
    [operation2 start];
}


///根据文件路径删除指定文件
-(void)removeFileByPath{
    NSError *err;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:&err];
}

#pragma mark - 右侧更多按钮
-(void)addRightNarBtn{
    ///知识库页面进入
    if ([self.viewFrom isEqualToString:@"knowledge"]) {
        UIButton *option = [UIButton buttonWithType:UIButtonTypeCustom];
        option.frame = CGRectMake(0, 0, 20, 4);
        [option setBackgroundImage:[UIImage imageNamed:@"more.png"]
                          forState:UIControlStateNormal];
        
        [option setBackgroundImage:[UIImage imageNamed:@"more.png"]
                          forState:UIControlStateHighlighted];
        
        
        [option addTarget:self action:@selector(showOptionMenu)
         forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:option];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    
}

-(void)showOptionMenu{
    /// 0 已收藏 1 未收藏
    NSInteger isfav = [[self.details safeObjectForKey:@"hasFavorite"] integerValue];
    
    NSString *report = @"举报";
    NSString *fav = @"";
    NSString *delete = @"从服务器删除";
    ///已收藏
    if (isfav == 0) {
        fav = @"取消收藏";
    }else{
        fav = @"收藏";
    }
    
    NSString *deleteLocal = @"";
    ///判断本地是否存在文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath]){
        NSLog(@"文件存在--->");
        deleteLocal = @"从本地删除";
    }else{
        NSLog(@"文件不存在--->");
        deleteLocal = @"";
    }
    
    
    NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
    long long userId = [[userInfo safeObjectForKey:@"id"] longLongValue];
    long long creatorId = -1;
    NSDictionary *creator = nil;
    if ([self.detailsOld objectForKey:@"creator"]) {
        creator = [self.detailsOld objectForKey:@"creator"];
    }
    
    if (creator) {
        creatorId = [[creator safeObjectForKey:@"id"] longLongValue];
    }
    
    ///可删除
    if (creatorId == userId) {
        ///  举报  收藏/取消收藏   从服务器删除
        UIActionSheet *actionSheet;
        if (![deleteLocal isEqualToString:@""]) {
            actionSheet = [[UIActionSheet alloc]
                           initWithTitle:nil
                           delegate:self
                           cancelButtonTitle:@"取消"
                           destructiveButtonTitle:nil
                           otherButtonTitles: report,fav,deleteLocal,delete,nil];
            actionSheet.tag = 101;
        }else{
            actionSheet = [[UIActionSheet alloc]
                           initWithTitle:nil
                           delegate:self
                           cancelButtonTitle:@"取消"
                           destructiveButtonTitle:nil
                           otherButtonTitles: report,fav,delete,nil];
            actionSheet.tag = 102;
        }
        
        
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
//        actionSheet.destructiveButtonIndex = 2;
        
        [actionSheet showInView:self.view];
    }else{
        ///  举报  收藏/取消收藏
        UIActionSheet *actionSheet;
        if (![deleteLocal isEqualToString:@""]) {
            actionSheet = [[UIActionSheet alloc]
                           initWithTitle:nil
                           delegate:self
                           cancelButtonTitle:@"取消"
                           destructiveButtonTitle:nil
                           otherButtonTitles: report,fav,deleteLocal,nil];
            actionSheet.tag = 103;
        }else{
            actionSheet = [[UIActionSheet alloc]
                           initWithTitle:nil
                           delegate:self
                           cancelButtonTitle:@"取消"
                           destructiveButtonTitle:nil
                           otherButtonTitles: report,fav,nil];
            actionSheet.tag = 104;
        }
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        
        [actionSheet showInView:self.view];
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    if (actionSheet.tag == 101) {
        if (buttonIndex == 0) {
            //举报
            NSLog(@"举报--->");
            [self reportToService];
        }else if (buttonIndex == 1) {
            //收藏 取消收藏
            NSLog(@"收藏 --->");
            /// 0 已收藏 1 未收藏
            NSInteger isfav = [[self.details safeObjectForKey:@"hasFavorite"] integerValue];
//            if ([self.details objectForKey:@"hasFavorite"]) {
//                isfav = [[self.details objectForKey:@"hasFavorite"] integerValue];
//            }
            
            NSString *url = @"";
            ///已收藏
            if (isfav == 0) {
                ///取消收藏
                url = KNOWLEDGE_CANCEL_COLLECTION;
            }else{
                ///收藏
                url = KNOWLEDGE_ADD_COLLECTION;
            }
            [self trendOption:url];
            
        }else if(buttonIndex == 2) {
            NSLog(@"本地删除 --->");
            //删除
            [self removeFileByPath];
            [self.navigationController popViewControllerAnimated:YES];
        }else if(buttonIndex == 3) {
            NSLog(@"服务器删除 --->");
            [self showAlertDeleteService];
            
        }
    }else if (actionSheet.tag == 102) {
        if (buttonIndex == 0) {
            //举报
            NSLog(@"举报--->");
            [self reportToService];
        }else if (buttonIndex == 1) {
            //收藏 取消收藏
            NSLog(@"收藏 --->");
            /// 0 已收藏 1 未收藏
            NSInteger isfav = [[self.details safeObjectForKey:@"hasFavorite"] integerValue];
//            if ([self.details objectForKey:@"hasFavorite"]) {
//                isfav = [[self.details objectForKey:@"hasFavorite"] integerValue];
//            }
            
            NSString *url = @"";
            ///已收藏
            if (isfav == 0) {
                ///取消收藏
                url = KNOWLEDGE_CANCEL_COLLECTION;
            }else{
                ///收藏
                url = KNOWLEDGE_ADD_COLLECTION;
            }
            [self trendOption:url];
            
        }else if(buttonIndex == 2) {
            NSLog(@"服务器删除 --->");
            [self showAlertDeleteService];
            
        }
    }else if (actionSheet.tag == 103) {
        if (buttonIndex == 0) {
            //举报
            NSLog(@"举报--->");
            [self reportToService];
        }else if (buttonIndex == 1) {
            //收藏 取消收藏
            NSLog(@"收藏 --->");
            /// 0 已收藏 1 未收藏
            NSInteger isfav = [[self.details safeObjectForKey:@"hasFavorite"] integerValue];
//            if ([self.details objectForKey:@"hasFavorite"]) {
//                isfav = [[self.details objectForKey:@"hasFavorite"] integerValue];
//            }
            
            NSString *url = @"";
            ///已收藏
            if (isfav == 0) {
                ///取消收藏
                url = KNOWLEDGE_CANCEL_COLLECTION;
            }else{
                ///收藏
                url = KNOWLEDGE_ADD_COLLECTION;
            }
            [self trendOption:url];
            
        }else if(buttonIndex == 2) {
            NSLog(@"本地删除 --->");
            //删除
            [self removeFileByPath];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if ( actionSheet.tag == 104){
        if (buttonIndex == 0) {
            //举报
            NSLog(@"举报--->");
            [self reportToService];
        }else if (buttonIndex == 1) {
            //收藏 取消收藏
            NSLog(@"收藏 --->");
            /// 0 已收藏 1 未收藏
            NSInteger isfav = [[self.details safeObjectForKey:@"hasFavorite"] integerValue];
//            if ([self.details objectForKey:@"hasFavorite"]) {
//                isfav = [[self.details objectForKey:@"hasFavorite"] integerValue];
//            }
            
            NSString *url = @"";
            ///已收藏
            if (isfav == 0) {
                ///取消收藏
                url = KNOWLEDGE_CANCEL_COLLECTION;
            }else{
                ///收藏
                url = KNOWLEDGE_ADD_COLLECTION;
            }
            [self trendOption:url];
            
        }
    }
}



-(void)showAlertDeleteService{
    UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:@"将从服务器中彻底删除文件" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertDelete.tag = 101;
    [alertDelete show];
}



#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            NSLog(@"删除文件");
            //删除
            [self trendOption:KNOWLEDGE_DELETE_SERVICE_FILE ];
        }
    }
}


#pragma mark - 举报
-(void)reportToService{
    ReportToServiceViewController *controller = [[ReportToServiceViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 收藏/取消收藏/赞/删除动态 删除评论
-(void)trendOption:(NSString *)url{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    long long fileId = -1;
    if ([self.details objectForKey:@"id"]) {
        fileId = [[self.details objectForKey:@"id"] longLongValue];
    }
    [params setObject:[NSNumber numberWithLongLong:fileId] forKey:@"id"];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,url] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@" responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self setViewRequestSusscessByTrendOptions:url];
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self trendOption:url];
            };
            [comRequest loginInBackground];
        }
        else{
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            NSLog(@"desc:%@",desc);
            if ([desc isEqualToString:@""]) {
                ///失败 做相应处理
                if ([url isEqualToString:KNOWLEDGE_ADD_COLLECTION]) {
                    desc = @"收藏失败";
                }else if([url isEqualToString:KNOWLEDGE_CANCEL_COLLECTION]){
                    desc = @"取消收藏失败";
                }else if([url isEqualToString:KNOWLEDGE_DELETE_SERVICE_FILE]){
                    desc = @"从服务器删除失败";
                }
            }
            ///失败 做相应处理
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [CommonFuntion showToast:NET_ERROR inView:self.view];
        [hud hide:YES];
        
    }];
}

// 收藏/取消收藏/赞/删除动态操作请求成功时数据处理
-(void)setViewRequestSusscessByTrendOptions:(NSString *)action
{
    ///收藏 取消收藏
    if ([action isEqualToString:KNOWLEDGE_ADD_COLLECTION] || [action isEqualToString:KNOWLEDGE_CANCEL_COLLECTION]) {
        if ([action isEqualToString:KNOWLEDGE_ADD_COLLECTION]) {
            NSLog(@"收藏成功---->");
            [CommonFuntion showToast:@"收藏成功" inView:self.view];
        }else if([action isEqualToString:KNOWLEDGE_CANCEL_COLLECTION]){
            [CommonFuntion showToast:@"取消收藏成功" inView:self.view];
        }
        [self updateFavFlag:action];
        if (self.UpdateFavStatus) {
            self.UpdateFavStatus(self.indexRow,action);
        }
        
    }else{
        if (self.DeleteFileFromService) {
            self.DeleteFileFromService();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - 更新收藏标记
-(void)updateFavFlag:(NSString *)action {
    NSLog(@"updateFavFlag  action:%@ ",action);
    NSInteger isfav = 1;
    if ([action isEqualToString:KNOWLEDGE_ADD_COLLECTION]) {
        isfav = 0;
    }else if([action isEqualToString:KNOWLEDGE_CANCEL_COLLECTION]){
        isfav = 1;
    }
    
    ///修改本地数据
    [self.details setObject:[NSNumber numberWithInteger:isfav] forKey:@"hasFavorite"];
}



///设置frame
-(void)setCurViewFrame{
    self.imgIcon.frame = CGRectMake((kScreen_Width-self.imgIcon.frame.size.width)/2, self.imgIcon.frame.origin.y, self.imgIcon.frame.size.width, self.imgIcon.frame.size.height);
    
    self.labelSize.frame = CGRectMake((kScreen_Width-self.labelSize.frame.size.width)/2, self.labelSize.frame.origin.y, self.labelSize.frame.size.width, self.labelSize.frame.size.height);
    
    self.labelName.frame = CGRectMake((kScreen_Width-self.labelName.frame.size.width)/2, self.labelName.frame.origin.y, self.labelName.frame.size.width, self.labelName.frame.size.height);
    
    self.btnPreview.frame = CGRectMake((kScreen_Width-self.btnPreview.frame.size.width)/2, self.btnPreview.frame.origin.y, self.btnPreview.frame.size.width, self.btnPreview.frame.size.height);

    self.viewProgress.frame = CGRectMake((kScreen_Width-self.viewProgress.frame.size.width)/2, self.viewProgress.frame.origin.y, self.viewProgress.frame.size.width, self.viewProgress.frame.size.height);
    
    self.webView.frame = CGRectMake(0, 64,kScreen_Width , kScreen_Height-64);
}


 
 /*
 NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:fileName];
 NSLog(@"path = %@",path);
 operation = [[DownLoadOperation alloc] init];
 [operation downloadWithUrl:url
 cachePath:^NSString *{
 NSLog(@"cachePath--->");
 return path;
 } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
 //                         NSLog(@"progressBlock--->");
 //                        NSLog(@"bytesRead = %u ,totalBytesRead = %llu totalBytesExpectedToRead = %llu",bytesRead,totalBytesRead,totalBytesExpectedToRead);
 float progress = totalBytesRead / (float)totalBytesExpectedToRead;
 
 [self.progressview setProgress:progress animated:YES];
 
 
 
 } success:^(AFHTTPRequestOperation *operation1, id responseObject) {
 
 NSLog(@"success---->");
 
 //                         [self.imgIcon setImage:image];
 //将NSData类型对象data写入文件，文件名为FileName
 [operation1.responseData writeToFile:fileName atomically:YES];
 
 [self showViewWithWebView];
 
 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 NSLog(@"failure--->");
 NSLog(@"error = %@",error);
 }];
 */



/*
 -(void)downloadFile:(NSString *)url{
 
 if ( sessionManager ) {
 sessionManager = nil ;
 }
 
 sessionManager = [[ AFURLSessionManager alloc ] initWithSessionConfiguration :[ NSURLSessionConfiguration defaultSessionConfiguration ]];
 
 // 添加请求接口
 
 NSURLRequest *request = [ NSURLRequest requestWithURL :[ NSURL URLWithString : url]];
 
 // 发送下载请求
 
 NSURLSessionDownloadTask *downloadTask = [ sessionManager downloadTaskWithRequest :request progress : nil destination :^ NSURL *( NSURL *targetPath, NSURLResponse *response) {
 
 
 
 
 NSURL *filePath = [ NSURL fileURLWithPath :[ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory , NSUserDomainMask , YES ) firstObject ]];
 
 //        return [filePath URLByAppendingPathComponent :[response suggestedFilename]];
 return [filePath URLByAppendingPathComponent :fileName];
 
 } completionHandler :^( NSURLResponse *response, NSURL *filePath, NSError *error) {
 
 // 下载完成
 
 NSLog ( @"Finish and Download to: %@" , filePath);
 
 UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:fileName];
 NSLog(@"imgFromUrl3:%@",imgFromUrl3);
 self.imgIcon.image = imgFromUrl3;
 
 }];
 
 
 NSProgress *progress = [sessionManager downloadProgressForTask:downloadTask];
 //    progress.completedUnitCount
 
 // 开始下载
 [downloadTask resume ];
 
 }
 */
@end
