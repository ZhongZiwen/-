//
//  EditItemTypeCellB.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditItemModel;

@interface EditItemTypeCellB : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnContent;

@property (strong, nonatomic) IBOutlet UIImageView *imgArrow;

@property (strong, nonatomic) IBOutlet UIButton *btnAction;


-(void)setCellDetail:(EditItemModel *)model;


///
@property (nonatomic, copy) void (^SelectDataTypeBlock)(NSInteger dataType);
///右边按钮事件
@property (nonatomic, copy) void (^SelectDataActionBlock)(NSInteger dataAction);

@end
