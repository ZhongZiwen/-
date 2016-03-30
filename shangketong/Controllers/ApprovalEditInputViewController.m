//
//  ApprovalEditInputViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalEditInputViewController.h"

@interface ApprovalEditInputViewController ()

@property (nonatomic, strong) UITextView *textView;
@end

@implementation ApprovalEditInputViewController
@synthesize rowDescriptor = _rowDescriptor;
@synthesize popoverController = __popoverController;

- (void)loadView {
    [super loadView];
    
    self.title = @"编辑";
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonItemPress)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.textView];
    _textView.text = _rowDescriptor.value;
    
    [_textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - setters and getters
- (void)leftButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemPress {
    _rowDescriptor.value = _textView.text;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - setters and getters
- (UITextView*)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        _textView.font = [UIFont systemFontOfSize:14];
        
    }
    return _textView;
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
