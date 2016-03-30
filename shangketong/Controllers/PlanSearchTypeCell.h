//
//  PlanSearchTypeCell.h
//  DemoMapViewPOI
//   筛选类型  
//  Created by sungoin-zjp on 15-5-13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanSearchTypeCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imgSelected;

-(void)setCellFrame;

@end
