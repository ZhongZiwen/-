//
//  CustomerRelatedCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-7-18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
@interface CustomerRelatedCell : SWTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;
@property (strong, nonatomic) IBOutlet UIButton *btnCall;

-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;
///设置左滑按钮
-(void)setLeftAndRightBtn;

@property (nonatomic, copy) void (^CallCusotmerBlock)(NSInteger index);
@end
