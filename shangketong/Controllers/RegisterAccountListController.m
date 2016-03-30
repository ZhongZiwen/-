//
//  RegisterAccountListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RegisterAccountListController.h"
#import "RegisterAccountListCell.h"
#import "NameIdModel.h"
#import "RegisterAccountLoginController.h"
#import "RegisterNewCompanyLoginController.h"

#define kCellIdentifier @"RegisterAccountListCell"

@interface RegisterAccountListController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@end

@implementation RegisterAccountListController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    [self.view addSubview:self.tableView];
    [self initBottomView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)createButtonPress {
    RegisterNewCompanyLoginController *newCompanyLoginController = [[RegisterNewCompanyLoginController alloc] init];
    newCompanyLoginController.title = @"创建新公司";
    newCompanyLoginController.accountName = _accountName;
    if (_isEmailRegister) {
        newCompanyLoginController.isEmailRegister = YES;
    }
    [self.navigationController pushViewController:newCompanyLoginController animated:YES];
}

#pragma mark - private method
- (UIView*)customHeaderView {
    NSString *string = [NSString stringWithFormat:@"%@已经是商客通用户并属于以下公司，是否要直接登录？", _accountName];
    CGFloat stringHeight = [string getHeightWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(kScreen_Width - 2 * kCellLeftWidth, CGFLOAT_MAX)];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20 + stringHeight + 10)];
    
    UILabel *label = [[UILabel alloc] init];
    [label setX:kCellLeftWidth];
    [label setY:20];
    [label setWidth:kScreen_Width - CGRectGetMinX(label.frame) * 2];
    [label setHeight:stringHeight];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor iOS7darkGrayColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    label.text = string;
    [headerView addSubview:label];
    
    return headerView;
}

- (void)initBottomView {
    UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [createButton setX:15];
    [createButton setY:kScreen_Height - 44];
    [createButton setWidth:kScreen_Width - 2 * 15];
    [createButton setHeight:44];
    createButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [createButton setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
    [createButton setTitle:@"不，我要创建新公司" forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(createButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createButton];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RegisterAccountListCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RegisterAccountListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    NameIdModel *item = _sourceArray[indexPath.row];
    [cell configWithObj:item];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:15.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NameIdModel *item = _sourceArray[indexPath.row];
    
    RegisterAccountLoginController *accountLoginController = [[RegisterAccountLoginController alloc] init];
    accountLoginController.title = @"登录";
    accountLoginController.item = item;
    accountLoginController.accountName = _accountName;
    [self.navigationController pushViewController:accountLoginController animated:YES];
}

#pragma mark - UIScrollView
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[RegisterAccountListCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableHeaderView = [self customHeaderView];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
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
