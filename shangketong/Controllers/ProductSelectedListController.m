//
//  ProductSelectedListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ProductSelectedListController.h"
#import "ProductCell.h"
#import "Product.h"

#define kCellIdentifier @"ProductCell"

@interface ProductSelectedListController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tempSourceArray;
@end

@implementation ProductSelectedListController

- (void)loadView {
    [super loadView];
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tempSourceArray = [[NSMutableArray alloc] initWithArray:_sourceArray];
    
    [_tableView configBlankPageWithTitle:@"暂无已选择产品" hasData:_sourceArray.count hasError:NO reloadButtonBlock:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ProductCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tenant_agree"]];
    Product *item = _sourceArray[indexPath.row];
    [cell configWithObj:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ProductCell *cell = (ProductCell*)[tableView cellForRowAtIndexPath:indexPath];

    Product *item = _sourceArray[indexPath.row];
    
    BOOL isExist = NO;
    for (int i = 0; i < _tempSourceArray.count; i ++) {
        Product *tempItem = _tempSourceArray[i];
        if ([tempItem.id isEqualToNumber:item.id]) {
            isExist = YES;
            [_tempSourceArray removeObjectAtIndex:i];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tenant_agree_selected"]];
            break;
        }
    }
    
    if (!isExist) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tenant_agree"]];
        [_tempSourceArray addObject:item];
    }
    
    self.title = [NSString stringWithFormat:@"已选择产品(%d)", _tempSourceArray.count];
    if (self.changeValueBlock) {
        self.changeValueBlock(item);
    }
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:0];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - 0];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ProductCell class] forCellReuseIdentifier:kCellIdentifier];
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
