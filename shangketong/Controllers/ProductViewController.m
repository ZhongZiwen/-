//
//  ProductViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ProductViewController.h"
#import "Product.h"
#import "ProductGroup.h"
#import "ProductContentsCell.h"
#import "ProductCell.h"
#import "ProductDetailViewController.h"
#import "ProductSelectedBottomView.h"
#import "ProductSelectedListController.h"

#define kCellIdentifier_contents @"ProductContentsCell"
#define kCellIdentifier @"ProductCell"

@interface ProductViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ProductSelectedBottomView *bottomView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;

- (void)sendRequstForList;
@end

@implementation ProductViewController

- (void)loadView {
    [super loadView];
    
    [self.view addSubview:self.tableView];
    
    if (_isAdd) {
        [self.view addSubview:self.bottomView];
        [_bottomView updateCountLabelWithCount:_selectedArray.count];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@20 forKey:@"pageSize"];
    [_params setObject:(_parentId ? : @"") forKey:@"parentId"];
    
    [self sendRequstForList];
    
    // 已选择产品列表
    @weakify(self);
    self.bottomView.bottomBtnPressBlock = ^{
        @strongify(self);
        ProductSelectedListController *selectedListController = [[ProductSelectedListController alloc] init];
        selectedListController.title = [NSString stringWithFormat:@"已选择产品(%d)", self.selectedArray.count];
        selectedListController.sourceArray = [[NSMutableArray alloc] initWithArray:self.selectedArray];
        selectedListController.changeValueBlock = ^(Product *item) {
            BOOL isExist = NO;
            for (int i = 0; i < self.selectedArray.count; i ++) {
                Product *tempItem = self.selectedArray[i];
                if ([tempItem.id isEqualToNumber:item.id]) {
                    isExist = YES;
                    [self.selectedArray removeObjectAtIndex:i];
                    break;
                }
            }
            
            if (!isExist) {
                [self.selectedArray addObject:item];
            }
            
            [self.tableView reloadData];
            [self.bottomView updateCountLabelWithCount:self.selectedArray.count];
        };
        [self.navigationController pushViewController:selectedListController animated:YES];
    };
    
    // 确定
    _bottomView.confireBtnPressBlock = ^{
        @strongify(self);
        NSString *productIds = @"";
        for (int i = 0; i < self.selectedArray.count; i ++) {
            Product *item = self.selectedArray[i];
            if (!i) {
                productIds = [NSString stringWithFormat:@"%@", item.id];
            }else {
                productIds = [NSString stringWithFormat:@"%@,%@", productIds, item.id];
            }
        }
        NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
        [tempParams setObject:productIds forKey:@"productIds"];
        
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Common_ProductList_WithPath:kNetPath_SaleChance_AddProduct params:tempParams block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                if (self.refreshBlock) {
                    self.refreshBlock();
                }
                [self.navigationController popToViewController:self.navigationController.viewControllers[3] animated:YES];
            }
        }];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)sendRequstForList {
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Product_List_WithParams:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            for (NSDictionary *tempDict in data[@"products"]) {
                Product *item = [NSObject objectOfClass:@"Product" fromJSON:tempDict];
                
                BOOL isExist = NO;
                for (ProductGroup *tempGroup in _sourceArray) {
                    if ([tempGroup.type isEqualToNumber:item.type]) {
                        isExist = YES;
                        [tempGroup.array addObject:item];
                        break;
                    }
                }
                
                if (!isExist) {
                    ProductGroup *group = [[ProductGroup alloc] init];
                    group.type = item.type;
                    [group.array addObject:item];
                    [_sourceArray addObject:group];
                }
            }
            [_tableView reloadData];
        }
        else {
            kShowHUD(@"获取数据失败");
        }
        [_tableView configBlankPageWithTitle:@"暂无产品" hasData:_sourceArray.count hasError:error != nil reloadButtonBlock:nil];
    }];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ProductGroup *item = _sourceArray[section];
    return item.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductGroup *item = _sourceArray[indexPath.section];
    if ([item.type integerValue] == 1) {
        return [ProductContentsCell cellHeight];
    }else {
        return [ProductCell cellHeight];
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    ProductGroup *group = _sourceArray[section];
    if ([group.type integerValue] == 1) {
        return @"产品目录";
    }else {
        return @"产品";
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductGroup *group = _sourceArray[indexPath.section];
    Product *item = group.array[indexPath.row];
    if ([group.type integerValue] == 1) {
        ProductContentsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_contents forIndexPath:indexPath];
        [cell configWithObj:item];
        return cell;
    }
    
    ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    [cell configWithObj:item];
    
    // 选择产品
    if (_isAdd) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tenant_agree"]];
        
        for (int i = 0; i < _selectedArray.count; i ++) {
            Product *tempItem = _selectedArray[i];
            if ([tempItem.id isEqualToNumber:item.id]) {
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tenant_agree_selected"]];
                break;
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_productCheck].location == NSNotFound) {
        kShowHUD(@"对不起，您暂时没有权限访问");
        return;
    }
    
    ProductGroup *group = _sourceArray[indexPath.section];
    Product *item = group.array[indexPath.row];
    
    if ([group.type integerValue] == 1) {   // 产品目录
        
        if (![item.child integerValue]) {
            return;
        }
        
        ProductViewController *productController = [[ProductViewController alloc] init];
        productController.title = item.name;
        productController.parentId = item.id;
        if (_isAdd) {
            productController.isAdd = YES;
            productController.selectedArray = _selectedArray;
            productController.selectedBlock = ^{
                [_tableView reloadData];
                [_bottomView updateCountLabelWithCount:_selectedArray.count];
            };
        }
        [self.navigationController pushViewController:productController animated:YES];
        return;
    }
    
    // 添加产品
    if (_isAdd) {
        
        ProductCell *cell = (ProductCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        BOOL isExist = NO;
        for (int i = 0; i < _selectedArray.count; i ++) {
            Product *tempItem = _selectedArray[i];
            if ([tempItem.id isEqualToNumber:item.id]) {
                isExist = YES;
                [_selectedArray removeObjectAtIndex:i];
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tenant_agree"]];
                break;
            }
        }
        if (!isExist) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tenant_agree_selected"]];
            [_selectedArray addObject:item];
        }
        
        [_bottomView updateCountLabelWithCount:_selectedArray.count];
        if (self.selectedBlock) {
            self.selectedBlock();
        }
        return;
    }
    
    // 产品详情
    ProductDetailViewController *detailController = [[ProductDetailViewController alloc] init];
    detailController.title = @"产品详情";
    detailController.productId = item.id;
    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tableView setY:0];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ProductContentsCell class] forCellReuseIdentifier:kCellIdentifier_contents];
        [_tableView registerClass:[ProductCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    }
    return _tableView;
}

- (ProductSelectedBottomView*)bottomView {
    if (!_bottomView) {
        _bottomView = [[ProductSelectedBottomView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 44, kScreen_Width, 44.0f)];
    }
    return _bottomView;
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
