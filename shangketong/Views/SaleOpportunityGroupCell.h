//
//  SaleOpportunityGroupCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-6-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaleOpportunityGroupCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelMoney;
@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;


-(void)setCellDetails:(NSDictionary *)item currencyUnit:(NSString *)unit ;
@end
