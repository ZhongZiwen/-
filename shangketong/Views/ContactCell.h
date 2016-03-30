//
//  ContactCell.h
//  shangketong
//  CRM - 联系人
//  Created by sungoin-zjp on 15-6-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>

@protocol ContactCellDelegate;

@interface ContactCell : SWTableViewCell

@property (assign, nonatomic) id <ContactCellDelegate>ccdelegate;

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelAccountName;


@property (strong, nonatomic) IBOutlet UIButton *btnSelected;



-(void)setCellFrame;
-(void)setCellDetails:(NSDictionary *)item;
///设置左滑按钮
-(void)setLeftAndRightBtn:(NSDictionary *)item;
///设置选中图标
-(void)setSelectedBtnShow:(NSString *)select;
///设置拨打电话图标
-(void)setCallBtnShow:(NSDictionary *)item index:(NSIndexPath *)indexPath;

@end


@protocol ContactCellDelegate<NSObject>
@required
///拨打联系人
- (void)callCantact:(NSInteger)index;
@end
