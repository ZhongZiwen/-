//
//  SaleLeadSearchCell.h
//  shangketong
//  搜索关联cell
//  Created by sungoin-zjp on 15-6-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaleLeadSearchCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;
@property (strong, nonatomic) IBOutlet UILabel *labelCompanyName;
@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelHighSeaStatus;
@property (strong, nonatomic) IBOutlet UIImageView *imgSplit;
@property (strong, nonatomic) IBOutlet UILabel *labelMarkInfo;



-(void)setCellDetails:(NSDictionary *)item;
@end
