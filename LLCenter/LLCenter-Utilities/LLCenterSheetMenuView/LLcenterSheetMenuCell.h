//
//  SheetMenuCell.h
//  shangketong
//  cell 类型A
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LLCenterSheetMenuModel;
@interface LLcenterSheetMenuCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelName;

@property (strong, nonatomic) IBOutlet UIImageView *imgSelect;



-(void)setCellDetails:(LLCenterSheetMenuModel *)item;

@end
