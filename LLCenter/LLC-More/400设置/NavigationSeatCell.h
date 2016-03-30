//
//  NavigationSeatCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-26.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationSeatCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelNo;
@property (strong, nonatomic) IBOutlet UILabel *labelPhone;


-(void)setCellDetails:(NSDictionary *)item;


@end
