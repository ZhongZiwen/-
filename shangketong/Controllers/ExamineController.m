//
//  ExamineController.m
//  shangketong
//
//  Created by 蒋 on 15/9/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ExamineController.h"
#import "UIViewController+NavDropMenu.h"
#import "AFNHttp.h"
#import "ExamineCell.h"

@interface ExamineController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataSourceArray; //数据源
@end

@implementation ExamineController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *V = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableViewExamine setTableFooterView:V];
    
    _dataSourceArray = [NSMutableArray arrayWithCapacity:0];
    
    [self customDownMenuWithType:TableViewCellTypeDefault andSource:@[@"审批中", @"中止", @"通过"] andDefaultIndex:0 andBlock:^(NSInteger index) {
        
    }];
    [self getDataSocrceFormSever];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSourceArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExamineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExamineCellIdentifier"];
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ExamineCell" owner:self options:nil];
        cell = (ExamineCell *)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    [cell initWithDictionary:_dataSourceArray[indexPath.row]];
    return cell;
}
- (void)getDataSocrceFormSever {
    NSMutableDictionary *parmas = [NSMutableDictionary dictionary];
    [parmas setObject:@"" forKey:@"id"];
    [parmas setObject:@"0" forKey:@"type"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP, GET_CAMPAIGN_DETAILS_APPROVAL] params:parmas success:^(id responseObj) {
        NSLog(@"---%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([responseObj objectForKey:@"approvals"]) {
                 _dataSourceArray = [responseObj objectForKey:@"approvals"];
            }
            [_tableViewExamine reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"---%@", error);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
