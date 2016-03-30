//
//  ProductDetailViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ColumnModel.h"
#import "ColumnSelectModel.h"
#import "Directory.h"
#import "XLFormTitleDetailCell.h"
#import "XLFormTitleImagesCell.h"
#import "XLFormFileCell.h"
#import "FileListDetailController.h"

@interface ProductDetailViewController ()

@property (strong, nonatomic) NSMutableDictionary *fileParams;

- (void)configFormViewWithArray:(NSArray*)array;
- (void)sendRequestForFileList;
@end

@implementation ProductDetailViewController

- (void)loadView {
    [super loadView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    XLFormDescriptor *formDescriptor = [XLFormDescriptor formDescriptor];
    self.form = formDescriptor;
    
    _fileParams = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_fileParams setObject:@1 forKey:@"pageNo"];
    [_fileParams setObject:@20 forKey:@"pageSize"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [params setObject:_productId forKey:@"id"];
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Product_Detail_WithParams:params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *tempDict in data[@"columns"]) {
                ColumnModel *item = [NSObject objectOfClass:@"ColumnModel" fromJSON:tempDict];
                for (NSDictionary *tempSelectDict in tempDict[@"select"]) {
                    ColumnSelectModel *selectItem = [NSObject objectOfClass:@"ColumnSelectModel" fromJSON:tempSelectDict];
                    [item.selectArray addObject:selectItem];
                }
                [item configResultWithDictionary:tempDict];
                [tempArray addObject:item];
            }
            [self configFormViewWithArray:tempArray];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configFormViewWithArray:(NSArray *)array {
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    for (ColumnModel *column in array) {
        
        if ([column.showWhenInit integerValue] == 0) {
            switch ([column.columnType integerValue]) {
                case 8: {   // section
                    section = [XLFormSectionDescriptor formSectionWithTitle:column.name];
                    [self.form addFormSection:section];
                }
                    break;
                case 10: {
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:column.propertyName rowType:XLFormRowDescriptorTypeTitleImages];
                    row.value = @[column];
                    [section addFormRow:row];
                }
                    break;
                default: {
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:column.propertyName rowType:XLFormRowDescriptorTypeTitleDetail];
                    row.value = column;
                    [section addFormRow:row];
                }
                    break;
            }
        }
        
    }
    
    [self sendRequestForFileList];
}

- (void)sendRequestForFileList {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Net_APIManager sharedManager] request_Common_File_List_WithPath:kNetPath_Product_FileList params:_fileParams block:^(id data, NSError *error) {
            if (data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    
                    if (![data[@"directorys"] count]) {
                        return;
                    }
                    
                    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSectionWithTitle:@"文件"];
                    XLFormRowDescriptor *row;
                    for (NSDictionary *tempDict in data[@"directorys"]) {
                        Directory *item = [NSObject objectOfClass:@"Directory" fromJSON:tempDict];
                        [item configFileTypeAndSize];
                        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"file" rowType:XLFormRowDescriptorTypeFile];
                        row.value = item;
                        [section addFormRow:row];
                    }
                    [self.form addFormSection:section];
                });
            }
            else {
                NSLog(@"获取文档列表失败");
            }
        }];
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XLFormRowDescriptor *rowDescriptor = [self.form formRowAtIndex:indexPath];
    if (![rowDescriptor.value isKindOfClass:[Directory class]]) {
        return;
    }
    
    Directory *item = rowDescriptor.value;
    
    FileListDetailController *detailController = [[FileListDetailController alloc] init];
    detailController.title = item.name;
    detailController.directory = item;
    detailController.isShowRightBarButton = YES;
    [self.navigationController pushViewController:detailController animated:YES];
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
