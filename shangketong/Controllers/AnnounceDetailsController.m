//
//  AnnounceDetailsController.m
//  shangketong
//
//  Created by 蒋 on 15/9/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AnnounceDetailsController.h"
#import "AFNHttp.h"

@interface AnnounceDetailsController ()<UIWebViewDelegate>{
    UIScrollView *scrollview;
}

@end

@implementation AnnounceDetailsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self getDataSourceFromSever];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 获取详情
- (void)getDataSourceFromSever {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_announceID forKey:@"id"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_ANNOUNCEMENT_DETAIL] params:params success:^(id responseObj) {
        NSDictionary *infos = responseObj;
        NSLog(@"公告详情responseObj:%@", [infos description]);
        [self creatView:infos];
        
    } failure:^(NSError *error) {
        
    }];
}


-(void)creatView:(NSDictionary *)details{
    if (details == nil) {
        return;
    }
    
    /*
     {
     content = "部门图片公告预览";
     createDate = 1450929751938;
     createUserName = "最长最长最长最长最长最长最长最";
     deptName = "全公司";
     desc = "<null>";
     readCount = 2;
     status = 0;
     title = "图片公告";
     totalCount = 4;
     }
     */
    
    scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height)];
    scrollview.showsVerticalScrollIndicator = YES;
    scrollview.contentSize = CGSizeMake(kScreen_Width, kScreen_Height);
    
    UIView *viewHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 85)];
    viewHead.backgroundColor = [UIColor clearColor];
    
    ///Title
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, kScreen_Width-30, 20)];
    labelTitle.font = [UIFont boldSystemFontOfSize:17.0];
    labelTitle.textColor = [UIColor blackColor];
    labelTitle.text = [details safeObjectForKey:@"title"];
    
    ///from
    UILabel *labelFrom = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, kScreen_Width-30, 20)];
    labelFrom.font = [UIFont boldSystemFontOfSize:14.0];
    labelFrom.textColor = [UIColor grayColor];
    labelFrom.text = [NSString stringWithFormat:@"来自%@ %@",[details safeObjectForKey:@"deptName"],[details safeObjectForKey:@"createUserName"]];
    
    
    ///Date + count
    UILabel *labelDateAndCount = [[UILabel alloc] initWithFrame:CGRectMake(15, 60, kScreen_Width-30, 20)];
    labelDateAndCount.font = [UIFont boldSystemFontOfSize:14.0];
    labelDateAndCount.textColor = [UIColor grayColor];
    
    NSString *strDate = @"";
    NSString *strCount = @"";
    strDate = [CommonFuntion transDateWithTimeInterval:[[details safeObjectForKey:@"createDate"] longLongValue] withFormat:@"yyyy-MM-dd HH:mm"];
    strCount = [NSString stringWithFormat:@"阅读(%@/%@)",[details safeObjectForKey:@"readCount"],[details safeObjectForKey:@"totalCount"]];
    labelDateAndCount.text = [NSString stringWithFormat:@"%@ %@",strDate,strCount];
    
    ///line
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(15, 83, kScreen_Width, 2)];
    line.image = [UIImage imageNamed:@"line.png"];
    
    [viewHead addSubview:labelTitle];
    [viewHead addSubview:labelFrom];
    [viewHead addSubview:labelDateAndCount];
    [viewHead addSubview:line];
    
    [scrollview addSubview:viewHead];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(5, 85, kScreen_Width-10, kScreen_Height-90-64)];
    webView.delegate = self;
    webView.userInteractionEnabled = NO;
    webView.scalesPageToFit = YES;
    webView.backgroundColor = [UIColor whiteColor];
    

    [webView loadHTMLString:[details safeObjectForKey:@"content"] baseURL:nil];
//    [webView loadHTMLString:self.announceContent baseURL:nil];
    
    [scrollview addSubview:webView];
    [self.view addSubview:scrollview];
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
//    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", webView.frame.size.width];
//    [webView stringByEvaluatingJavaScriptFromString:meta];
    
// [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '250%'"];
    
    float webViewHeight=[webView.scrollView contentSize].height;
    
    CGRect newFrame = webView.frame;
    newFrame.size.height = webViewHeight;
    webView.frame =  newFrame;
    scrollview.contentSize = CGSizeMake(kScreen_Width, webViewHeight+85+64);
}


@end
