//
//  EditItemTypeCellF.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditItemModel;

@interface EditItemTypeCellF : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

@property (strong, nonatomic) IBOutlet UIButton *btnContent;
@property (strong, nonatomic) IBOutlet UIImageView *imgArrow;


-(void)setCellDetail:(EditItemModel *)model;

///
@property (nonatomic, copy) void (^SelectDataTypeBlock)(NSInteger dataType);

@end
