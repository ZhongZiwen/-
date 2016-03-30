//
//  InputViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "InputViewController.h"
#import "UIView+Common.h"
#import "UIPlaceHolderTextView.h"
#import "AFNHttp.h"
#import "CommonConstant.h"
#import <MBProgressHUD.h>
#import "ApprovalSelectViewController.h"
#import "CommonFuntion.h"

#define kContentFont [UIFont systemFontOfSize:16]

@interface InputViewController ()<UIScrollViewDelegate, UITextViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIPlaceHolderTextView *contentTextView;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) UILabel *reveiwerLabel;
@property (nonatomic, strong) NSMutableDictionary *params;
@end

@implementation InputViewController
@synthesize rowDescriptor = _rowDescriptor;
@synthesize popoverController = __popoverController;

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonItemPress)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:(_rightButtonString ? : @"确定") style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(kScreen_Width, kScreen_Height + 1);
    [self.view addSubview:scrollView];
    
    [scrollView addSubview:self.contentTextView];
    if (self.rowDescriptor) {
        if (self.rowDescriptor.value) {
            _contentTextView.text = self.rowDescriptor.value;
        }
        else {
            _contentTextView.placeholder = self.rowDescriptor.noValueDisplayText;
        }
    }
    else {
        if (![_textString isEqualToString:@"无备注"]) {
            _contentTextView.text = _textString;
        }
        _contentTextView.placeholder = _placeholderString;
    }
    
    if ([self.title isEqualToString:@"同意申请"] && _approvalIsLastNode) {
        [self.view addSubview:self.toolView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.title isEqualToString:@"同意申请"] && _approvalIsLastNode) {
        [self addObserverOfKeyBoard];
    }
    
//    [_contentTextView becomeFirstResponder];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_contentTextView becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_contentTextView resignFirstResponder];
//    _contentTextView = nil;
    if ([self.title isEqualToString:@"同意申请"] && _approvalIsLastNode) {
        [self removeObserverOfKeyBoard];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _params = [[NSMutableDictionary alloc] init];
    [_params addEntriesFromDictionary:COMMON_PARAMS];
    [_params setObject:@(_approvalId) forKey:@"id"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 添加键盘事件监听
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

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = _toolView.frame;
    
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];

    _toolView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = _toolView.frame;

    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    _toolView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

#pragma mark - event response
- (void)leftButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemPress {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (self.rowDescriptor) {
        self.rowDescriptor.value = _contentTextView.text;
        
        if (self.popoverController){
            [self.popoverController dismissPopoverAnimated:YES];
            [self.popoverController.delegate popoverControllerDidDismissPopover:self.popoverController];
        }else if ([self.parentViewController isKindOfClass:[UINavigationController class]]){
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    
    if (_delegateType == ValueDelegateTypeXLForm) {
        
    }else if (_delegateType == ValueDelegateTypeBlock) {
        if (self.valueBlock) {
            self.valueBlock(@{@"text" : [_rowDescriptor.value objectForKey:@"text"],
                              @"value" : ([_contentTextView.text length] ? _contentTextView.text : @"无备注"),
                              @"isEdit" : [_rowDescriptor.value objectForKey:@"isEdit"]});
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else { // 审批
        
        
        NSString *postString;
        
        if ([self.title isEqualToString:@"同意申请"]) {
            if (![_contentTextView.text length]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请填写同意理由" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
                return;
            }
            [_params setObject:_contentTextView.text forKey:@"remark"];

            // 最后一个节点
            if (!_approvalIsLastNode) {
                [_params setObject:appDelegateAccessor.moudle.userId forKey:@"reveiwerId"];
            }else { // 不是最后一个节点
                // 判断是否已选择审批人
                if (![_params objectForKey:@"reveiwerId"]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请选择一个审批人" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                    return;
                }
            }

        }else if ([self.title isEqualToString:@"拒绝申请"]) {
            
            if (![_contentTextView.text length]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请填写拒绝理由" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
                return;
            }
            
            [_params setObject:_contentTextView.text forKey:@"remark"];

            [_params setObject:appDelegateAccessor.moudle.userId forKey:@"reveiwerId"];
        }
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud show:YES];
        
        if ([self.title isEqualToString:@"同意申请"]) {
            
            postString = [NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Approve_Agree];
            
        }else { // 拒绝申请
            
            postString = [NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Approve_Refuse];
        }
        
        __weak typeof(self) weak_self = self;
        [AFNHttp post:postString params:_params success:^(id responseObj) {
            [hud hide:YES];
            if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
                if (self.refreshBlock) {
                    self.refreshBlock();
                }
                [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
            }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [weak_self rightButtonItemPress];
                };
                [comRequest loginInBackground];
            }
            else  {
                NSString *desc = @"";
                desc = [responseObj objectForKey:@"desc"];
                if ([desc isEqualToString:@""]) {
                    desc = @"操作失败";
                }
                kShowHUD(desc,nil)
                
            }
        } failure:^(NSError *error) {
            [hud hide:YES];
            kShowHUD(NET_ERROR,nil)
        }];
    }
}

- (void)choiceButtonPress {
    
    if (_approvalAssignable == 0 && _approvalReveiwer && _approvalReveiwer.count > 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"选择指定审批人", @"选择其他审批人", nil];
        [actionSheet showInView:self.view];
    }else if (_approvalAssignable == 0) {
        ///选审批人
        __weak typeof(self) weak_self = self;
        ApprovalSelectViewController *selectController = [[ApprovalSelectViewController alloc] init];
        selectController.valueBlock = ^(NSDictionary *dict) {
            weak_self.reveiwerLabel.text = dict[@"name"];
            [weak_self.params setObject:dict[@"id"] forKey:@"reveiwerId"];
        };
        [self.navigationController pushViewController:selectController animated:YES];
    }else {
        __weak typeof(self) weak_self = self;
        ApprovalSelectViewController *selectController = [[ApprovalSelectViewController alloc] init];
        selectController.approvalReveiwer = _approvalReveiwer;
        selectController.valueBlock = ^(NSDictionary *dict) {
            weak_self.reveiwerLabel.text = dict[@"name"];
            [weak_self.params setObject:dict[@"id"] forKey:@"reveiwerId"];
        };
        [self.navigationController pushViewController:selectController animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 200) {
        if (buttonIndex == 0) {
            
        }
    } else {
        if (actionSheet.cancelButtonIndex == buttonIndex)
            return;
        
        __weak typeof(self) weak_self = self;
        ApprovalSelectViewController *selectController = [[ApprovalSelectViewController alloc] init];
        if (buttonIndex == 0) {
            selectController.approvalReveiwer = _approvalReveiwer;
        }
        selectController.valueBlock = ^(NSDictionary *dict) {
            weak_self.reveiwerLabel.text = dict[@"name"];
            [weak_self.params setObject:dict[@"id"] forKey:@"reveiwerId"];
        };
        [self.navigationController pushViewController:selectController animated:YES];

    }
}
#pragma mark -- AlertView
- (void)blackRefreshAlertView:(NSString *)string {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:string delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.refreshBlock) {
        self.refreshBlock();
    }
    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_contentTextView resignFirstResponder];
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
}

#pragma mark - setters and getters
- (UIPlaceHolderTextView*)contentTextView {
    if (!_contentTextView) {
        _contentTextView = [[UIPlaceHolderTextView alloc] initWithFrame:self.view.bounds];
        _contentTextView.font = kContentFont;
        _contentTextView.delegate = self;
        _contentTextView.returnKeyType = UIReturnKeyDefault;
    }
    return _contentTextView;
}

- (UIView*)toolView {
    if (!_toolView) {
        _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 44, kScreen_Width, 44)];
        [_toolView addLineUp:YES andDown:NO];
        
        CGSize sizeLabelTtile = [CommonFuntion getSizeOfContents:@"选择下一级审批人 " Font:[UIFont systemFontOfSize:14.0] withWidth:(kScreen_Width-120) withHeight:44];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, sizeLabelTtile.width, 44)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"选择下一级审批人";
        [_toolView addSubview:label];
        
        
        
        UIImage *image = [UIImage imageNamed:@"activity_to_detail_normal"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(kScreen_Width - image.size.width - 15, (44 - image.size.height) / 2.0, image.size.width, image.size.height);
        [_toolView addSubview:imageView];
        
        _reveiwerLabel = [[UILabel alloc] initWithFrame:CGRectMake(sizeLabelTtile.width+30, 0, kScreen_Width - sizeLabelTtile.width-30 - image.size.width - 15 - 5 , 44)];
        _reveiwerLabel.font = [UIFont systemFontOfSize:14];
        _reveiwerLabel.textColor = [UIColor blackColor];
        _reveiwerLabel.textAlignment = NSTextAlignmentRight;
        [_toolView addSubview:_reveiwerLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = _toolView.bounds;
        [button addTarget:self action:@selector(choiceButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [_toolView addSubview:button];
    }
    return _toolView;
}
- (void)dealloc {
    _contentTextView = nil;
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
