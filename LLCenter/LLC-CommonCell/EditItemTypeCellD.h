//
//  EditItemTypeCellD.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditItemModel;

@interface EditItemTypeCellD : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelTitle;


@property (strong, nonatomic) IBOutlet UIImageView *imgComp;
@property (strong, nonatomic) IBOutlet UIImageView *imgPersonal;
@property (strong, nonatomic) IBOutlet UIButton *btnComp;
@property (strong, nonatomic) IBOutlet UIButton *btnPersonal;

-(void)setCellDetail:(EditItemModel *)model andLeftTitle:(NSString *)leftTitle andRightTitle:(NSString *)rightTitle;

///0客户 1个人
@property (nonatomic, copy) void (^SelectCustomerTypeBlock)(NSInteger customerType);

@end
