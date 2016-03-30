//
//  EditItemTypeCellA.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditItemModel;

@interface EditItemTypeCellA : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UITextField *textFieldContent;


-(void)setCellDetail:(EditItemModel *)model;

@property (nonatomic, copy) void(^textValueChangedBlock) (NSString*);

@end
