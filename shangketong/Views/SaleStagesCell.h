//
//  SaleStagesCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-7-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaleStagesCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgCheck;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

@property (strong, nonatomic) IBOutlet UIImageView *imgLineV;



-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath andIsCanChecked:(BOOL)isCanChecked;

@end
