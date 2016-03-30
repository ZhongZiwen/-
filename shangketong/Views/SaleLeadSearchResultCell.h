//
//  SaleLeadSearchResultCell.h
//  shangketong
//  搜索结果cell
//  Created by sungoin-zjp on 15-6-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaleLeadSearchResultCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelCompanyName;


-(void)setCellDetails:(NSDictionary *)item;

@end
