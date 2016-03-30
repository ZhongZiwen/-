//
//  DetailCellA.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditItemModel;

@interface DetailCellA : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelLeft;
@property (strong, nonatomic) IBOutlet UILabel *lableRight;

-(void)setCellDetail:(EditItemModel *)model;

@end
