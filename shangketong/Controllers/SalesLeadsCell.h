//
//  SalesLeadsCell.h
//  shangketong
//
//  Created by 蒋 on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SalesLeadsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (void)initWithDictionary:(NSDictionary *)dict;
- (void)setFrameForAllPhones;
@end
