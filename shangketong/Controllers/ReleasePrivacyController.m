//
//  ReleasePrivacyController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ReleasePrivacyController.h"
#import "ReleasePrivacyListController.h"
#import "ReleasePrivacyItem.h"

#define kCellIdentifier @"UITableViewCell"

@interface ReleasePrivacyController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation ReleasePrivacyController

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
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSArray *imageArray = @[@"feed_post_public_gray", @"feed_post_group_gray", @"feed_post_group_gray"];
    NSArray *titleArray = @[@"公开", @"仅发送给某一部门", @"仅发送给某一群组"];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageArray[indexPath.row]]];
    cell.textLabel.text = titleArray[indexPath.row];
    
    if (_privacyItem.indexRow == indexPath.row) {
        if (_privacyItem.indexRow) {
            [cell.contentView addSubview:self.detailLabel];
        }else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        [_detailLabel removeFromSuperview];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _privacyItem.indexRow = indexPath.row;
        _privacyItem.privacyString = @"公开";
        if (self.selectRowBlock) {
            self.selectRowBlock(_privacyItem);
        }
    }else {
        __weak typeof(self) weak_self = self;
        ReleasePrivacyListController *listController = [[ReleasePrivacyListController alloc] init];
        if (indexPath.row == 1) {
            listController.title = @"选择一个部门";
        }else if (indexPath.row == 2) {
            listController.title = @"选择一个群组";
        }
        listController.indexRow = indexPath.row;
        listController.privacyItem = _privacyItem;
        listController.selectRowBlock = ^(ReleasePrivacyItem *item) {
            if (weak_self.selectRowBlock) {
                weak_self.selectRowBlock(item);
            }
        };
        [self.navigationController pushViewController:listController animated:YES];
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

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 120 - 30, 0, 120, 54)];
        _detailLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        _detailLabel.textColor = LIGHT_BLUE_COLOR;
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.text = _privacyItem.privacyString;
    }
    return _detailLabel;
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
