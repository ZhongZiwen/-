//
//  SortNavigationSitCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SortNavigationSitCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelNo;


@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

-(void)setCellDetails:(NSDictionary *)item;

@end
