//
//  KnowledgeDepartmentCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-6-13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KnowledgeDepartmentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelName;



-(void)setCellFrame;
-(void)setCellDetails:(NSDictionary *)item;

@end
