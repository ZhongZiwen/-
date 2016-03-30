//
//  MassMsgViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MassMsgViewController.h"
#import "CommonConstant.h"

@interface MassMsgViewController (){
    UITextView *textView;
}

@end

@implementation MassMsgViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = VIEW_BG_COLOR;
    self.title = @"输入短信内容";
    [self addNarOkBtn];
    [self initCurView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [textView resignFirstResponder];
}


#pragma mark - 确定按钮
-(void)addNarOkBtn{

    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(okBtnPressed)];
    self.navigationItem.rightBarButtonItem = okButton;
}

///确定
-(void)okBtnPressed{
    NSLog(@"ok--->");
    if ([[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"内容不能为空"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    [self sendMessage];
}

#pragma mark - 初始化view
-(void)initCurView{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, 50)];
    headView.backgroundColor = [UIColor colorWithRed:244.0f/255 green:244.0f/255 blue:244.0f/255 alpha:1.0f];
    
    
    UILabel *labelTag = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 60, 20)];
    labelTag.font = [UIFont systemFontOfSize:12.0];
    labelTag.textColor = [UIColor grayColor];
    labelTag.text = @"收件人:";
    
    UILabel *labelContact = [[UILabel alloc] initWithFrame:CGRectMake(70, 15, kScreen_Width-90, 20)];
    labelContact.font = [UIFont systemFontOfSize:12.0];
    labelContact.textColor = [UIColor blackColor];
    if ([self.typeContact isEqualToString:@"contact"] || [self.typeContact isEqualToString:@"customer"]) {
        labelContact.text = [self getContactsName];
    }else if ([self.typeContact isEqualToString:@"commondetailscall"] || [self.typeContact isEqualToString:@"userinfo"]){
       labelContact.text = self.contactName;
    }
    
    [headView addSubview:labelTag];
    [headView addSubview:labelContact];
    [self.view addSubview:headView];
    
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 114, kScreen_Width, kScreen_Height-114)];
    
    textView.font = [UIFont systemFontOfSize:15.0];
    textView.keyboardType = UIKeyboardTypeDefault;
    [textView becomeFirstResponder];
    [self.view addSubview:textView];
}


///获取联系人姓名
-(NSString *)getContactsName{
    NSMutableString *strNames = [[NSMutableString alloc] init];
    NSInteger count = 0;
    if (self.arrayAllContact) {
        count = [self.arrayAllContact count];
    }
    for (int i=0; i<count; i++) {
        if (i == 0) {
            [strNames appendString:[[self.arrayAllContact objectAtIndex:i] objectForKey:@"name"]];
        }else{
            [strNames appendString:[NSString stringWithFormat:@",%@",[[self.arrayAllContact objectAtIndex:i] objectForKey:@"name"]]];
        }
    }
    return strNames;
}


///获取联系人手机号
-(NSArray *)getContactsPhone{
    NSMutableArray *arratPhones = [[NSMutableArray alloc] init];
    NSInteger count = 0;
    NSString *strPhoneKey = @"";
    if (self.arrayAllContact) {
        count = [self.arrayAllContact count];
    }
    if ([self.typeContact isEqualToString:@"contact"]) {
        strPhoneKey = @"mobile";
    }else if ([self.typeContact isEqualToString:@"customer"]){
        strPhoneKey = @"phone";
    }
    
    for (int i=0; i<count; i++) {
        if (![[[self.arrayAllContact objectAtIndex:i] objectForKey:strPhoneKey] isEqualToString:@""]) {
            [arratPhones addObject:[[self.arrayAllContact objectAtIndex:i] objectForKey:strPhoneKey]];
        }
    }
    
    return arratPhones;
}

///发送短信
- (void)sendMessage
{
    MFMessageComposeViewController *messageComposer;
    NSArray *recipients;
    ///客户或联系人
    if ([self.typeContact isEqualToString:@"contact"] || [self.typeContact isEqualToString:@"customer"]) {
        recipients=[self getContactsPhone];
    }else if ([self.typeContact isEqualToString:@"commondetailscall"] || [self.typeContact isEqualToString:@"userinfo"]){
        recipients=[NSArray arrayWithObjects:self.contactPhone, nil];
    }
    
    if([MFMessageComposeViewController canSendText])
    {
        messageComposer=[[MFMessageComposeViewController alloc] init];
        messageComposer.messageComposeDelegate = self;
        [messageComposer setRecipients:recipients];//设置接收者
        [messageComposer setBody:textView.text];//设置发送内容
#warning 待测试
        if ([[[UIDevice currentDevice] systemVersion] intValue] == 7) {
            [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        }
        [self presentViewController:messageComposer animated:NO completion:Nil];
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"该设备不支持短信功能"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
        [alert show];
        
    }
}
//  timed out waiting for fence barrier from com.apple.mobilesms.compose
// 发送短信的委托方法
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultSent:
        {
            NSLog(@"短信发出成功");
            [self resultMsg:TRUE desc:@""];
            break;
        }
        case MessageComposeResultFailed:{
            NSLog(@"短信发出失败");
            [self resultMsg:FALSE desc:@"发送失败"];
            break;
        }
        case MessageComposeResultCancelled:
        {
            NSLog(@"短信被用户取消发出");
            [self resultMsg:FALSE desc:@""];
            break;
        }
        default:
            [self dismissViewControllerAnimated:YES completion:nil];
        break;
    }
}

///发送结果
-(void)resultMsg:(BOOL) isSuccess desc:(NSString *)desc{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(resultOfMassMsg:desc:)]) {
        [self.delegate resultOfMassMsg:isSuccess desc:desc];
    }
    
    if (!isSuccess) {
        [textView becomeFirstResponder];
    }
}

@end
