//
//  EditItemTypeCellG.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditItemModel;
@interface EditItemTypeCellG : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *btnWeek1;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek2;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek3;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek4;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek5;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek6;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek7;

- (IBAction)selectWeekAction:(id)sender;



-(void)setCellDetail:(EditItemModel *)model;
-(void)setCellFrame;


@property (nonatomic, copy) void (^SelectWeekBlock)(NSInteger indexOfWeek);

@end
