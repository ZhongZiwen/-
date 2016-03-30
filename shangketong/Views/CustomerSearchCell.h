//
//  CustomerSearchCell.h
//  shangketong
//  客户-搜索关联cell
//  Created by sungoin-zjp on 15-6-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomerCellDelegate;
@interface CustomerSearchCell : UITableViewCell

@property (assign, nonatomic) id <CustomerCellDelegate>ccdelegate;

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;
@property (strong, nonatomic) IBOutlet UILabel *labelMarkInfo;
@property (strong, nonatomic) IBOutlet UIImageView *imgSplit;
@property (strong, nonatomic) IBOutlet UIButton *btnFollow;

-(void)setCellDetails:(NSDictionary *)item index:(NSIndexPath *)indexPath;

@end

@protocol CustomerCellDelegate<NSObject>
@required
///关注操作
- (void)followCustomer:(NSInteger)index;
@end
