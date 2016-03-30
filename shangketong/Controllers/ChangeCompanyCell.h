//
//  ChangeCompanyCell.h
//  shangketong
//   切换公司
//  Created by sungoin-zjp on 15-7-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeCompanyCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imgCheck;

-(void)setCellDetails:(NSDictionary *)item;

@end
