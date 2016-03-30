//
//  MessageViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageHeaderCell.h"
#import "MessageContentCell.h"
#import <MessageUI/MessageUI.h>
#import "MsgViewController.h"
#import "Lead.h"
#import "Customer.h"
#import "Contact.h"

#define kCellIdentifier_header @"MessageHeaderCell"
#define kCellIdentifier_content @"MessageContentCell"

@interface MessageViewController ()<UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (copy, nonatomic) NSString *contentStr;
@end

@implementation MessageViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"上一步" target:self action:@selector(leftButtonPress)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"确定" target:self action:@selector(rightButtonPress)];
    
    @weakify(self);
    RAC(self.navigationItem.rightBarButtonItem, enabled) =
    [RACSignal combineLatest:@[RACObserve(self, contentStr)] reduce:^id (NSString *mdStr){
                                   @strongify(self);
                                   return @(![self isEmptyContent]);
                               }];
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    MessageContentCell *cell = (MessageContentCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if ([cell respondsToSelector:@selector(becomeFirstResponder)]) {
        [cell becomeFirstResponder];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isEmptyContent{
    BOOL isEmptyContent = YES;
    if (_contentStr && [_contentStr length]) {
        isEmptyContent = NO;
    }
    return isEmptyContent;
}

#pragma mark - event response
- (void)leftButtonPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonPress {
    
    [self.view endEditing:YES];

    NSMutableArray *phonesArray = [NSMutableArray arrayWithCapacity:0];
    for (id tempObj in _sourceArray) {
        if ([tempObj isKindOfClass:[Lead class]]) {
            Lead *lead = tempObj;
            if (lead.mobile) {
                [phonesArray addObject:lead.mobile];
            }
        }else if ([tempObj isKindOfClass:[Customer class]]) {
            Customer *customer = tempObj;
            if (customer.phone) {
                [phonesArray addObject:customer.phone];
            }
        }
        else if ([tempObj isKindOfClass:[Contact class]]) {
            Contact *contact = tempObj;
            if (contact.mobile) {
                [phonesArray addObject:contact.mobile];
            }
        }
    }
    
    [self showMessageView:phonesArray title:nil body:_contentStr];
}

#pragma mark - private method
- (void)showMessageView:(NSArray*)phones title:(NSString*)title body:(NSString*)body {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = phones;
        controller.navigationBar.tintColor = [UIColor whiteColor];
        controller.body = body;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"该设备不支持短信功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent: {
            for (UIViewController *viewConroller in self.navigationController.viewControllers) {
                if ([viewConroller isKindOfClass:[MsgViewController class]]) {
                    [self.navigationController popToViewController:viewConroller animated:YES];
                    break;
                }
            }
        }
            // 信息发送成功
            break;
        case MessageComposeResultFailed:
            // 信息发送失败
            break;
        case MessageComposeResultCancelled:
            // 信息被用户取消发送
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _tableView) {
        [self.view endEditing:YES];
    }
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.row) {
        return [MessageHeaderCell cellHeightWithArray:_sourceArray];
    }
    
    return [MessageContentCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.row) {
        MessageHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_header forIndexPath:indexPath];
        [cell configWithArray:_sourceArray];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
        return cell;
    }
    
    @weakify(self);
    MessageContentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_content forIndexPath:indexPath];
    cell.textValueChangedBlock = ^(NSString *str) {
        @strongify(self);
        self.contentStr = str;
    };
    return cell;
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[MessageHeaderCell class] forCellReuseIdentifier:kCellIdentifier_header];
        [_tableView registerClass:[MessageContentCell class] forCellReuseIdentifier:kCellIdentifier_content];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
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
