//
//  EditItemTypeCellC.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditItemModel;

@interface EditItemTypeCellC : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollviewTag;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectTag;



-(void)setCellDetail:(EditItemModel *)model;

@property (nonatomic, copy) void (^SelectTagsBlock)(void);
@end
