//
//  SaleOpportunityCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-6-24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
@protocol SaleOpportunityCellDelegate;
@interface SaleOpportunityCell : SWTableViewCell

@property (assign, nonatomic) id <SaleOpportunityCellDelegate>sodelegate;

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelPrice;
@property (strong, nonatomic) IBOutlet UIImageView *imgSplit;
@property (strong, nonatomic) IBOutlet UILabel *labelCompanyName;
@property (strong, nonatomic) IBOutlet UIButton *btnFollow;


-(void)setCellDetails:(NSDictionary *)item currencyUnit:(NSString *)unit index:(NSIndexPath *)indexPath ;
-(void)setFollowBtnShow:(NSDictionary *)item index:(NSIndexPath *)indexPath;
///设置左滑按钮
-(void)setLeftAndRightBtn:(NSDictionary *)item;
@end


@protocol SaleOpportunityCellDelegate<NSObject>
@required
///关注操作
- (void)followCustomer:(NSInteger)index;
@end
