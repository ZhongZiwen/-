//
//  ScheduleSelectedListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ScheduleSelectedListController.h"
#import <XLFormRowDescriptor.h>
#import "NewScheduleEndRepeatViewController.h"

#define kCellIdentifier @"UITableViewCell"

@interface ScheduleSelectedListController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ScheduleSelectedListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kView_BG_Color;
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = [_dataSource[indexPath.row] objectForKey:@"title"];
    
    if ([[_dicPlanInfo objectForKey:@"isRepeat"] integerValue] == 1) {
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }else{
        
        if ([[_dicPlanInfo objectForKey:@"repeatType"] integerValue] == [[_dataSource[indexPath.row] objectForKey:@"tag"] integerValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
    // 如果点击的是已标记行，则直接跳转返回
    if ([[_rowDescriptor.value objectForKey:@"value"] isEqualToString:_dataSource[indexPath.row]]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (self.valueBlock) {
        self.valueBlock(@{@"text" : [_rowDescriptor.value objectForKey:@"text"], @"value" : [_dataSource[indexPath.row] objectForKey:@"title"], @"isEdit" : [_rowDescriptor.value objectForKey:@"isEdit"]}, [[_dataSource[indexPath.row] objectForKey:@"tag"] integerValue]);
        [self.navigationController popViewControllerAnimated:YES];
    }
     */
    
    ///修改日程详情
    if (self.flagOfPlanUpdate && [self.flagOfPlanUpdate isEqualToString:@"update-schedule"]) {
        if (indexPath.row == 0) {
            ///不重复
            if ([[_rowDescriptor.value objectForKey:@"value"] isEqualToString:_dataSource[indexPath.row]]) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            
            if (self.valueBlock) {
                self.valueBlock(@{@"text" : [_rowDescriptor.value objectForKey:@"text"], @"value" : @"不重复", @"isEdit" : [_rowDescriptor.value objectForKey:@"isEdit"]}, 0);
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }else{
            NewScheduleEndRepeatViewController  *controller = [[NewScheduleEndRepeatViewController alloc] init];
            controller.flagOfPlanUpdate = self.flagOfPlanUpdate;
            controller.dicPlanInfo = self.dicPlanInfo;
            controller.rowDescriptor = _rowDescriptor;
            controller.repeatType = [[_dataSource[indexPath.row] objectForKey:@"tag"] integerValue];
            controller.valueDateBlock = ^(){
                if (self.valueDateBlock) {
                    self.valueDateBlock();
                }
                [self.navigationController popViewControllerAnimated:YES];
            };
            
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }else{
        // 如果点击的是已标记行，则直接跳转返回
        if ([[_dicPlanInfo objectForKey:@"repeatType"] integerValue] == [[_dataSource[indexPath.row] objectForKey:@"tag"] integerValue]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        if (self.valueBlock) {
            self.valueBlock(@{@"text" : [_rowDescriptor.value objectForKey:@"text"], @"value" : [_dataSource[indexPath.row] objectForKey:@"title"], @"isEdit" : [_rowDescriptor.value objectForKey:@"isEdit"]}, [[_dataSource[indexPath.row] objectForKey:@"tag"] integerValue]);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        
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
