//
//  EditItemTypeCellRemarkShow.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditItemModel;

@interface EditItemTypeCellRemarkShow : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelContent;
@property (strong, nonatomic) IBOutlet UIImageView *imgContentBg;



-(void)setCellDetail:(EditItemModel *)model;
+(CGFloat)getCellHeight:(EditItemModel *)model;



@end
