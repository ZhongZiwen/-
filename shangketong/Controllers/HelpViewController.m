//
//  HelpViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-8-6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#define URL_HELP @"http://sunke.com/sunkemobile/faq.html"

#import "HelpViewController.h"
#import "CommonFuntion.h"
#import "CommonNoDataView.h"

@interface HelpViewController ()<UIWebViewDelegate>
{
    UILabel *labelTitle;
}
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) UIWebView *webviewHelp;
@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 30)];
    labelTitle.font = [UIFont systemFontOfSize:20];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = labelTitle;
    
    ///检查是否有网络
    if (![CommonFuntion checkNetworkState]) {
        labelTitle.text = @"帮助";
        if (self.commonNoDataView == nil) {
            self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"list_empty.png" Title:@"请检查网络" optionBtnTitle:@""];
        }
        [self.view addSubview:self.commonNoDataView];
        return;
    }
    
    self.webviewHelp = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webviewHelp];
    self.webviewHelp.delegate = self;
    self.webviewHelp.backgroundColor = [UIColor whiteColor];
     NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL_HELP]];
    [self.webviewHelp loadRequest:request];
}


/*
 UIButton *backButton=[UIButton buttonWithType:UIButtonTypeCustom];
 backButton.frame=CGRectMake(0, 0, 60, 30);
 [backButton setImage:[UIImage imageNamed:@"NaviBtn_Back.png"] forState:UIControlStateNormal];
 [backButton setImage:[UIImage imageNamed:@"NaviBtn_Back_H.png"] forState:UIControlStateHighlighted];
 [backButton addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
 
 UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
 self.navigationItem.leftBarButtonItem = backItem;
 
 */


-(void)leftButtonPress{
    if ([self.webviewHelp canGoBack]) {
        [self.webviewHelp goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    labelTitle = nil;
    _webviewHelp = nil;
    _commonNoDataView = nil;
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
//    NSLog(@"webViewDidStartLoad");
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
//    NSLog(@"webViewDidFinishLoad");
//    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
//    NSLog(@"currentURL:%@",currentURL);
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    NSLog(@"title:%@",title);
    
    if (title) {
        labelTitle.text = title;
    }
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    NSLog(@"didFailLoadWithError:%@", error);
}

@end
