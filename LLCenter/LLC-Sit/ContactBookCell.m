//
//  ContactBookCell.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-24.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "ContactBookCell.h"
#import "ContactBookDetailViewController.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "ContactBookPersonCell.h"

@interface ContactBookCell ()<UITableViewDelegate,UITableViewDataSource> {
    
}
@end

@implementation ContactBookCell

@synthesize parentViewController;

- (void)setCellDataInfo:(CellDataInfo*)cInfo {
    dataSource = [[NSMutableArray alloc] initWithArray:[cInfo.cellDataInfo objectForKey:@"data"]];
    labelTitle.text = [NSString stringWithFormat:@"%@(%ld)",[cInfo.cellDataInfo safeObjectForKey:@"title"],[dataSource count]];
    
    CGRect sRect = self.frame;
    if (cInfo.expanded) {
        btnExpand.selected = NO;
        tbView.hidden = NO;
        CGRect tbRect = tbView.frame;
        tbRect.size.height = [dataSource count] * 50.f;
        tbView.frame = tbRect;
        
        sRect.size.height = tbView.frame.size.height + 40.0f;
    }
    else {
        btnExpand.selected = YES;
        tbView.hidden = YES;
        sRect.size.height = 40.0f;
    }
    
    self.frame = sRect;
    
    [tbView reloadData];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    static NSString *CellIdentifier = @"ContactBookPersonCell";//cell重用标识
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];//设置这个cell的重用标识
    
    //若cell为nil，重新alloc一个cell
    if(!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ContactBookPersonCell" owner:self options:nil] objectAtIndex:0];
    }
    */
    
    ContactBookPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactBookPersonCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ContactBookPersonCell" owner:self options:nil];
        cell = (ContactBookPersonCell*)[array objectAtIndex:0];
        [cell setCellViewFrame];
    }
    
    ContactsInfo *currentCellDataInfo = [dataSource objectAtIndex:indexPath.row];
    cell.tag = indexPath.row;
    
    [cell setCellDataInfo:currentCellDataInfo];
    
    /*
    if([cell respondsToSelector:@selector(setCellDataInfo:)]){
        [cell performSelector:@selector(setCellDataInfo:) withObject:currentCellDataInfo];
    }
     */
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tbView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"Cell No.%d clicked",indexPath.row);
    if (parentViewController) {
        ContactBookDetailViewController *cdVc = [[ContactBookDetailViewController alloc] init];
        ContactsInfo *currentCellDataInfo = [dataSource objectAtIndex:indexPath.row];
        cdVc.detailContactInfo = currentCellDataInfo;
        cdVc.groupName = currentCellDataInfo.departmentNameList;
        cdVc.groupId = currentCellDataInfo.departmentIdList;
        
        
        NSLog(@"currentCellDataInfo:%@",[dataSource objectAtIndex:indexPath.row]);
        NSLog(@"detailContactInfo:%@",currentCellDataInfo);
        NSLog(@"groupName:%@",currentCellDataInfo.departmentNameList);
        NSLog(@"groupId:%@",currentCellDataInfo.departmentIdList);
        
//        [parentViewController.navigationController pushViewController:cdVc animated:YES];
        [parentViewController.tabBarController.navigationController pushViewController:cdVc animated:YES];
      
    }
}


#pragma mark - UI适配
-(void)setCellViewFrame
{
    if (DEVICE_IS_IPHONE6) {
        [self setViewByIphone6];
        
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
        [self setViewByIphone6];
    }

}

-(void)setViewByIphone6
{
    NSInteger vX = DEVICE_BOUNDS_WIDTH-320;
    
    view_headview.frame = [CommonFunc setViewFrameOffset:view_headview.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    view_headline.frame = [CommonFunc setViewFrameOffset:view_headline.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    btnExpand.frame = [CommonFunc setViewFrameOffset:btnExpand.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
    tbView.frame = [CommonFunc setViewFrameOffset:tbView.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    
}


@end
