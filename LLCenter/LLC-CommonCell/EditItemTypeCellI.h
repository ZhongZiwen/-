//
//  EditItemTypeCellI.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-19.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditItemModel;

@interface EditItemTypeCellI : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UISwitch *switchDefault;


- (IBAction)switchDefaultItem:(id)sender;


-(void)setCellDetail:(EditItemModel *)model;

@property (nonatomic, copy) void (^SwitchDefaultBlock)(NSString *isOn);

@end
