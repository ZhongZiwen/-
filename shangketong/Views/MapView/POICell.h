//
//  POICell.h
//  DemoMapViewPOI
//
//  Created by sungoin-zjp on 15-5-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POICell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *lableName;
@property (strong, nonatomic) IBOutlet UILabel *lableSteet;
@property (strong, nonatomic) IBOutlet UIImageView *imgSelected;


-(void)setCellFrame;
@end
