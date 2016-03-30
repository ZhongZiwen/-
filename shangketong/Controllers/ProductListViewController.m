//
//  ProductListViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ProductListViewController.h"
#import "PopoverView.h"
#import "PopoverItem.h"
#import "ProductDetailViewController.h"
#import "ProductPresentController.h"
#import "Product.h"
#import "ProductListCell.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"
#import "ProductViewController.h"
#import "MJRefresh.h"
#import <SBJson4Writer.h>

#define kCellIdentifier @"ProductListCell"

@interface ProductListViewController ()<UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UILabel *totalLabel;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableArray *editSourceArray;
@property (strong, nonatomic) NSMutableArray *changeSourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) SBJson4Writer *jsonParser;
@property (assign, nonatomic) BOOL isEdit;

- (void)sendRequestForList;
@end

@implementation ProductListViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithIcon:@"menu_showMore" showBadge:YES target:self action:@selector(moreButtonItemPress)];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.refreshBlock) {
        self.refreshBlock();
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _editSourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _changeSourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@20 forKey:@"pageSize"];
    
    [self.view beginLoading];
    [self sendRequestForList];
    
    [_tableView addHeaderWithTarget:self action:@selector(sendRequestForRefresh)];
    [_tableView addFooterWithTarget:self action:@selector(sendRequestForReloadMore)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequestForList {
    [[Net_APIManager sharedManager] request_Common_ProductList_WithPath:kNetPath_SaleChance_ProductsList params:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        [_tableView headerEndRefreshing];
        [_tableView footerEndRefreshing];
        if (data) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"products"]) {
                Product *item = [NSObject objectOfClass:@"Product" fromJSON:tempDict];
                [tempArray addObject:item];
            }
            if ([_params[@"pageNo"] isEqualToNumber:@1]) {
                _sourceArray = tempArray;
            }
            else {
                [_sourceArray addObjectsFromArray:tempArray];
            }
            
            if (tempArray.count == 20) {
                _tableView.footerHidden = NO;
            }
            else {
                _tableView.footerHidden = YES;
            }
            
            _totalLabel.text = [NSString stringWithFormat:@"产品: %@  总金额: %@元", data[@"totalNumber"], [self.numberFormatter stringFromNumber:data[@"totalMoney"]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
            
            [_tableView configBlankPageWithTitle:@"暂无产品" hasData:_sourceArray.count hasError:error != nil reloadButtonBlock:nil];
        }
    }];
}

- (void)sendRequestForRefresh {
    [_params setObject:@1 forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequestForList];
    });
}

- (void)sendRequestForReloadMore {
    [_params setObject:@([_params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequestForList];
    });
}

#pragma mark - event response
- (void)moreButtonItemPress {
    NSArray *array = @[[PopoverItem initItemWithTitle:@"编辑" image:nil target:self action:@selector(editProduct)],
                       [PopoverItem initItemWithTitle:@"添加产品" image:nil target:self action:@selector(addProduct)]];
    
    PopoverView *popView = [[PopoverView alloc] initWithImageItems:nil titleItems:array];
    [popView show];
}

- (void)editProduct {
    self.isEdit = YES;
}

- (void)addProduct {
    ProductViewController *productController = [[ProductViewController alloc] init];
    productController.title = @"选择产品";
    productController.isAdd = YES;
    productController.selectedArray = [[NSMutableArray alloc] initWithCapacity:0];
    productController.refreshBlock = ^{
        [self sendRequestForList];
    };
    [self.navigationController pushViewController:productController animated:YES];
}

- (void)cancelButtonItemPress {
    self.isEdit = NO;
}

- (void)saveButtonItemPress {
    
    NSString *jsonString = [self.jsonParser stringWithObject:_changeSourceArray];
    
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempParams setObject:(jsonString ? : @"") forKey:@"json"];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Common_ProductList_WithPath:kNetPath_SaleChance_SaveProduct params:tempParams block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            
            self.isEdit = NO;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self sendRequestForList];
            });
        }
    }];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isEdit) {
        return _editSourceArray.count;
    }
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ProductListCell cellHeight];
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"移除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !_isEdit;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Product *item;
    if (_isEdit) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit_doc"]];
        item = _editSourceArray[indexPath.row];
    }else {
        cell.accessoryView = nil;
        item = _sourceArray[indexPath.row];
    }
    [cell configWithObj:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Product *item;
    
    if (_isEdit) {
        item = _editSourceArray[indexPath.row];
        ProductPresentController *presentController = [[ProductPresentController alloc] init];
        presentController.transitioningDelegate = self;
        presentController.modalPresentationStyle = UIModalPresentationCustom;
        presentController.item = item;
        presentController.refreshBlock = ^{
            
            NSLog(@"number = %@", item.number);
            
            NSDictionary *tempDict = @{@"id" : item.id, @"count" : item.number};
            BOOL isExist = NO;
            for (int i = 0; i < _changeSourceArray.count; i ++) {
                NSDictionary *dict = _changeSourceArray[i];
                if ([dict[@"id"] isEqualToNumber:tempDict[@"id"]]) {
                    isExist = YES;
                    [_changeSourceArray replaceObjectAtIndex:i withObject:tempDict];
                    break;
                }
            }
            
            if (!isExist) {
                [_changeSourceArray addObject:tempDict];
            }
            
            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        [self.navigationController presentViewController:presentController animated:YES completion:nil];
        return;
    }
    
    item = _sourceArray[indexPath.row];
    ProductDetailViewController *detailController = [[ProductDetailViewController alloc] init];
    detailController.title = @"产品详情";
    detailController.productId = item.productId;
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Product *item = _sourceArray[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
            [tempParams setObject:item.id forKey:@"id"];
            [[Net_APIManager sharedManager] request_Common_ProductList_WithPath:kNetPath_SaleChance_RemoveProduct params:tempParams block:^(id data, NSError *error) {
                if (data) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @strongify(self);
                        [self.sourceArray removeObjectAtIndex:indexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                    });
                }
            }];
        });
    }
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return [PresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [DismissingAnimator new];
}

#pragma mark - setters and getters
- (void)setIsEdit:(BOOL)isEdit {
    _isEdit = isEdit;
    
    if (_isEdit) {
        
        _tableView.headerHidden = YES;
        _tableView.footerHidden = YES;
        [_editSourceArray removeAllObjects];
        for (Product *tempItem in _sourceArray) {
            Product *item = [tempItem copy];
            [_editSourceArray addObject:item];
        }
        
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(cancelButtonItemPress)];
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"保存" target:self action:@selector(saveButtonItemPress)];
        
        [_tableView reloadData];
        return;
    }
    
    _tableView.headerHidden = NO;
    _tableView.footerHidden = NO;
    [_changeSourceArray removeAllObjects];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithIcon:@"menu_showMore" showBadge:YES target:self action:@selector(moreButtonItemPress)];
    [_tableView reloadData];
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame) - 54];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ProductListCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (UIView*)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        [_bottomView setY:kScreen_Height - 54];
        [_bottomView setWidth:kScreen_Width];
        [_bottomView setHeight:54];
        _bottomView.backgroundColor = kView_BG_Color;
        [_bottomView addLineUp:YES andDown:NO];
        
        [_bottomView addSubview:self.totalLabel];
    }
    return _bottomView;
}

- (UILabel*)totalLabel {
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] init];
        [_totalLabel setX:15];
        [_totalLabel setWidth:kScreen_Width - CGRectGetMinX(_totalLabel.frame) * 2];
        [_totalLabel setHeight:20];
        [_totalLabel setCenterY:CGRectGetHeight(_bottomView.bounds) / 2];
        _totalLabel.font = [UIFont systemFontOfSize:16];
        _totalLabel.textColor = [UIColor iOS7darkGrayColor];
        _totalLabel.textAlignment = NSTextAlignmentLeft;
        _totalLabel.text = @"产品: 0  总金额: 0元";
    }
    return _totalLabel;
}

- (NSNumberFormatter*)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    }
    return _numberFormatter;
}

- (SBJson4Writer*)jsonParser {
    if (!_jsonParser) {
        _jsonParser = [[SBJson4Writer alloc] init];
    }
    return _jsonParser;
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
