//
//  FeedbackViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FeedbackViewController.h"
#import "AFNHttp.h"
#import <MBProgressHUD.h>

@interface FeedbackViewController ()<UITextViewDelegate,UIAlertViewDelegate>{
    UITextView *textviewFeedback;
}

@end

@implementation FeedbackViewController

- (void)loadView
{
    [super loadView];
    self.title = @"意见反馈";
    self.view.backgroundColor = kView_BG_Color;
    [self addSendBtn];
    [self initCurView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [textviewFeedback becomeFirstResponder];
    [self addObserverOfKeyBoard];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObserverOfKeyBoard];
}

#pragma mark - 发送按钮
-(void)addSendBtn{
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(sendBtnPressed)];
    self.navigationItem.rightBarButtonItem = okButton;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}


-(void)leftButtonPress{
    
    if ([[textviewFeedback.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定放弃已填写内容?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 1001;
        alertView.delegate = self;
        [alertView show];
    }
}

#pragma mark - delegate UIAlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1001) {
        // 退出
        if(buttonIndex == 0)
        {
        }
        else if(buttonIndex == 1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


-(void)sendBtnPressed{
    [self sendCmd];
}


#pragma mark - 初始化view
-(void)initCurView{
    textviewFeedback = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    textviewFeedback.font = [UIFont systemFontOfSize:15.0];
    textviewFeedback.keyboardType = UIKeyboardTypeDefault;
    textviewFeedback.delegate = self;
    [self.view addSubview:textviewFeedback];
}


#pragma mark - UITextViewDelegate
// 限制textView字数
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
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

- (void)textViewDidChange:(UITextView *)textView {
    
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
    
    if ([[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }else{
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

#pragma mark - 发送请求
-(void)sendCmd{
    [textviewFeedback resignFirstResponder];
    
    if ([[textviewFeedback.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        kShowHUD(@"意见内容不能为空");
        return;
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:textviewFeedback.text forKey:@"content"];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA, FEED_BACK_ACTION] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            kShowHUD(@"反馈成功");
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"反馈失败";
            }
            kShowHUD(desc,nil);
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [hud hide:YES];
        kShowHUD(NET_ERROR);
    }];
}





//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = textviewFeedback.frame;
    containerFrame.size.height = self.view.bounds.size.height - keyboardBounds.size.height-10;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    textviewFeedback.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    textviewFeedback.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    
    // commit animations
    [UIView commitAnimations];
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




@end
