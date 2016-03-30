//
//  RelatedBusinessController.m
//  shangketong
//
//  Created by 蒋 on 15/12/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RelatedBusinessController.h"
#import "RelatedSearchController.h"

@interface RelatedBusinessController (){
    ///业务code
    NSArray *arrBusinessCode;
}
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@end

@implementation RelatedBusinessController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关联业务";
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    self.tableView.scrollEnabled = NO;
    
    ///审批  根据初始化信息返回  获取需要显示的业务
    if (self.flagOfRelevance && [self.flagOfRelevance isEqualToString:@"approval"]) {
        _dataSourceArray = [[NSMutableArray alloc] init];
        if (self.businessCode && self.businessCode.length > 0) {
            arrBusinessCode = [self.businessCode componentsSeparatedByString:@","];

            arrBusinessCode = [arrBusinessCode sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
                if ([obj1 integerValue] < [obj2 integerValue]) return NSOrderedAscending;
                
                else if ([obj1 integerValue] > [obj2 integerValue]) return NSOrderedDescending;
                
                else return NSOrderedSame;
            }];
            
            for (int i=0; i<arrBusinessCode.count; i++) {
                [_dataSourceArray addObject:[self getBusinessNameByCode: [[arrBusinessCode objectAtIndex:i] integerValue]]];
            }
        }
    }else{
        _dataSourceArray = [NSMutableArray arrayWithObjects:@"客户", @"联系人", @"销售机会", @"销售线索", @"市场活动", nil];
    }
    
    
}

#pragma mark - 区分审批相关方法
///获取关联业务名称
//type类型 客户， 联系人， 销售机会， 销售线索， 市场活动
//public final static int CRM_TYPE_ACTIVITY = 201;             //市场活动
//public final static int CRM_TYPE_CLUE = 202;                 //销售线索
//public final static int CRM_TYPE_CUSTOMER = 203;             //客户
//public final static int CRM_TYPE_CONTRACT = 204;             //联系人
//public final static int CRM_TYPE_OPPORTUNITY = 205;          //销售机会
-(NSString *)getBusinessNameByCode:(NSInteger)code{
    NSString *name = @"";
    switch (code) {
        case 201:
            name = @"市场活动";
            break;
        case 202:
            name = @"销售线索";
            break;
        case 203:
            name = @"客户";
            break;
        case 204:
            name = @"联系人";
            break;
        case 205:
            name = @"销售机会";
            break;
        default:
            break;
    }
    return name;
}

///适配审批  获取点击业务类型的下标
/// :@"客户", @"联系人", @"销售机会", @"销售线索", @"市场活动", nil];
-(NSInteger)getBusinessIndexByCode:(NSInteger)code{
    NSInteger indexRow = 0;
    switch (code) {
        case 201:
            indexRow = 4;
            break;
        case 202:
            indexRow = 3;
            break;
        case 203:
            indexRow = 0;
            break;
        case 204:
            indexRow = 1;
            break;
        case 205:
            indexRow = 2;
            break;
            
        default:
            break;
    }
    return indexRow;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSourceArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _dataSourceArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    RelatedSearchController *controller = [[RelatedSearchController alloc] init];
    controller.flagOfRelevance = self.flagOfRelevance;
    if (self.flagOfRelevance && [self.flagOfRelevance isEqualToString:@"approval"]) {
        controller.businessCode = [arrBusinessCode objectAtIndex:indexPath.row];
    }
    
    controller.titleName = _dataSourceArray[indexPath.row];
    ///审批  根据初始化信息返回  获取需要显示的业务
    if (self.flagOfRelevance && [self.flagOfRelevance isEqualToString:@"approval"]) {
        controller.activityType = [self getBusinessIndexByCode: [[arrBusinessCode objectAtIndex:indexPath.row] integerValue]];
    }else{
        //type类型 客户， 联系人， 销售机会， 销售线索， 市场活动
        NSArray *typeArray = @[@"203", @"204", @"205", @"202", @"201"];
        controller.activityType = indexPath.row;
        controller.businessCode = typeArray[indexPath.row];
        NSLog(@"其他---indexPath.row :%ti",indexPath.row);
    }
    
    [self.navigationController pushViewController:controller animated:YES];

}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
