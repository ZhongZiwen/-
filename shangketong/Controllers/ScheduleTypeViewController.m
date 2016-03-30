//
//  ScheduleTypeViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ScheduleTypeViewController.h"
#import "ScheduleType.h"
#import "ScheduleTypeCell.h"

#define kCellIdentifier @"ScheduleTypeCell"

@interface ScheduleTypeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, strong) NSMutableArray *sourceArray;
@end

@implementation ScheduleTypeViewController
@synthesize rowDescriptor = _rowDescriptor;
@synthesize popoverController = __popoverController;

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Schedule_Type_WithBlock:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            for (NSDictionary *tempDict in data[@"salesParameter"]) {
                ScheduleType *scheduleType = [NSObject objectOfClass:@"ScheduleType" fromJSON:tempDict];
                [_sourceArray addObject:scheduleType];
            }
            
            ScheduleType *otherType = [[ScheduleType alloc] init];
            otherType.id = @0;
            otherType.color = @5;
            otherType.name = @"其他";
            otherType.title = @"";
            [_sourceArray addObject:otherType];
            
            [_tableView reloadData];
            
        }else {
            
        }
    }];
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
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ScheduleTypeCell cellHeight];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"选择类型，便于您区分和统计日程";
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScheduleTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    ScheduleType *item = _sourceArray[indexPath.row];
    [cell configWithObj:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ScheduleType *tempItem = _sourceArray[indexPath.row];
    tempItem.title = _item.title;
    if (self.valueBlock) {
        self.valueBlock(tempItem);
        [self.navigationController popViewControllerAnimated:YES];
    }
    //    self.rowDescriptor.value = item;
    //
    //    if (self.popoverController){
    //        [self.popoverController dismissPopoverAnimated:YES];
    //        [self.popoverController.delegate popoverControllerDidDismissPopover:self.popoverController];
    //    }else if ([self.parentViewController isKindOfClass:[UINavigationController class]]){
    //        [self.navigationController popViewControllerAnimated:YES];
    //    }
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ScheduleTypeCell class] forCellReuseIdentifier:kCellIdentifier];
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
