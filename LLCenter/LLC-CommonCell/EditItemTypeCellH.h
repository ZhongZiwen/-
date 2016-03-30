//
//  EditItemTypeCellH.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditItemModel;

@interface EditItemTypeCellH : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnCheckBox;

- (IBAction)checkBoxAction:(id)sender;

-(void)setCellDetail:(EditItemModel *)model;

@property (nonatomic, copy) void (^SelectMessageBlock)(void);

@end
