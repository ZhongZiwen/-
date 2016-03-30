//
//  RootMenuHeaderCell.h
//  shangketong
//  主菜单cell
//  Created by sungoin-zjp on 15-12-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RootMenuHeaderCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelCompany;
@property (strong, nonatomic) IBOutlet UIImageView *imgArrow;


-(void)setCellDetails:(NSDictionary *)item;

@end
