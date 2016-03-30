//
//  SheetmenuCellC.h
//  shangketong
//  cell 类型C
//  Created by sungoin-zjp on 15-6-16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetMenuModel.h"
@interface SheetmenuCellC : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

-(void)setCellDetails:(SheetMenuModel *)item;

@end
