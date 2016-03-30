//
//  RootMenuCell.h
//  shangketong
//  主菜单cell
//  Created by sungoin-zjp on 15-12-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootMenuModel.h"

@interface RootMenuCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imgRedCircle;
@property (strong, nonatomic) IBOutlet UILabel *labelNum;
@property (strong, nonatomic) IBOutlet UIImageView *imgArrow;

@property (strong, nonatomic) IBOutlet UIImageView *imgNewMsg;



///type 0 CRM  1 OA  2Me
-(void)setCellDetails:(RootMenuModel *)item withType:(NSInteger)type;

@end
