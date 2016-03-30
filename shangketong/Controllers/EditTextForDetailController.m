//
//  EditTextForDetailController.m
//  shangketong
//
//  Created by 蒋 on 15/8/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EditTextForDetailController.h"
#import "MBProgressHUD.h"
@interface EditTextForDetailController ()<UITextViewDelegate>

@end

@implementation EditTextForDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    // Do any additional setup after loading the view from its nib.
    self.textView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    [self initDataForTextView];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_textView becomeFirstResponder];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addObserverOfKeyBoard];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObserverOfKeyBoard];
}

- (void)initDataForTextView {
    _textView.delegate = self;
    _textView.text = _textStr;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPress:)];
    leftButtonItem.tag = 100;
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPress:)];
    rightButtonItem.tag = 101;
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}
- (void)backButtonPress:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 100:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 101:
            if (_backTextViewValveBlock) {
                _backTextViewValveBlock(_textView.text);
            }
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }

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
    CGRect containerFrame = self.textView.frame;
    containerFrame.size.height = self.view.bounds.size.height - keyboardBounds.size.height-10;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.textView.frame = containerFrame;
    
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
    
    self.textView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
