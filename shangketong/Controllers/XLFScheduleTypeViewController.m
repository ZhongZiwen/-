//
//  XLFScheduleTypeViewController.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFScheduleTypeViewController.h"
#import "XLFScheduleTypeCell.h"

#import <XLForm.h>

#import "CommonFuntion.h"

#define kCellIdentifier @"XLFScheduleTypeCell"

@interface XLFScheduleTypeViewController ()

@property (nonatomic, copy) NSString *titleHeaderSection;
@property (nonatomic, copy) NSString *titleFooterSection;
@end

@implementation XLFScheduleTypeViewController

- (id)initWithStyle:(UITableViewStyle)style andTitleHeaderSection:(NSString *)titleHeaderSection andTitleFooterSection:(NSString *)titleFooterSection {
    self = [super initWithStyle:style];
    if (self) {
        self.titleHeaderSection = titleHeaderSection;
        self.titleFooterSection = titleFooterSection;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[XLFScheduleTypeCell class] forCellReuseIdentifier:kCellIdentifier];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (NSArray*)selectorOptions {
    return self.rowDescriptor.selectorOptions;
}

//- (NSInteger)getIndexFromArrayForItem:(id)item {
//    for (id selectedValueItem in [self selectorOptions]) {
//        if ([[selectedValueItem displayText] isEqual:[item displayText]]) {
//            return [[self selectorOptions] indexOfObject:selectedValueItem];
//        }
//    }
//    return NSNotFound;
//}

- (NSInteger)getIndexFromArrayForItem:(NSString *)title {
    for (id selectedValueItem in [self selectorOptions]) {
        if ([[selectedValueItem displayText] isEqual:title]) {
            return [[self selectorOptions] indexOfObject:selectedValueItem];
        }
    }
    return NSNotFound;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self selectorOptions].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [XLFScheduleTypeCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XLFScheduleTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    id cellObject = [[self selectorOptions] objectAtIndex:indexPath.row];
    
    [cell configWithImageName:[CommonFuntion createImageWithColor:[CommonFuntion getColorValueByColorType:[[cellObject valueData] integerValue]]] andText:[cellObject displayText]];
    
    if ([self.rowDescriptor.title isEqual:[cellObject displayText]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _titleHeaderSection;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return _titleFooterSection;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XLFScheduleTypeCell *cell = (XLFScheduleTypeCell*)[tableView cellForRowAtIndexPath:indexPath];
    id cellObject = [self selectorOptions][indexPath.row];
    
    if ([self.rowDescriptor.title isEqual:[cellObject displayText]]) {    // 如果点击的是已标记行，则直接跳转返回
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    // 取消原选定行,重新标记选中行
    NSInteger index = [self getIndexFromArrayForItem:self.rowDescriptor.title];
    if (index != NSNotFound) {
        NSIndexPath *oldSelectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        XLFScheduleTypeCell *oldSelectedCell = (XLFScheduleTypeCell*)[tableView cellForRowAtIndexPath:oldSelectedIndexPath];
        oldSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    self.rowDescriptor.title = [cellObject displayText];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
