//
//  POITableViewController.m
//  DemoMapViewPOI
//
//  Created by sungoin-zjp on 15-5-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "POITableViewController.h"
#import "POICell.h"

@interface POITableViewController ()

@end

@implementation POITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择地址";
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    NSLog(@"poiArray:%@",self.poiArray);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.poiArray) {
        return [self.poiArray count]+1;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POICell *cell = [tableView dequeueReusableCellWithIdentifier:@"POICellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"POICell" owner:self options:nil];
        cell = (POICell*)[array objectAtIndex:0];
    }
    
    [cell setCellFrame];
    
    cell.clipsToBounds = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    
    [self setContentValue:cell forCurIndex:indexPath];
    
    return cell;
}


// cell  详情
-(void)setContentValue:(POICell *)cell forCurIndex:(NSIndexPath *)index
{
    NSInteger row = index.row;
    cell.imgSelected.hidden = YES;
    if (row == 0) {
        cell.imgSelected.hidden = NO;
        cell.lableName.text = self.curLocationName;
        cell.lableSteet.text = self.curLocationStreet;
    }else{
        NSDictionary *item = [self.poiArray objectAtIndex:row-1];
        MKMapItem *mapItem = (MKMapItem *)item;
        
        cell.lableName.text = mapItem.name;
        cell.lableSteet.text = [mapItem.placemark.addressDictionary objectForKey:@"Street"];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    [self.navigationController popViewControllerAnimated:YES];
    if (row == 0) {
        
    }else{

        if (self.delegate && [self.delegate respondsToSelector:@selector(notifyMapViewBySelectedPOI:)]) {
            [self.delegate notifyMapViewBySelectedPOI:(MKMapItem *)[self.poiArray objectAtIndex:row-1]];
        }
    }
}

@end
