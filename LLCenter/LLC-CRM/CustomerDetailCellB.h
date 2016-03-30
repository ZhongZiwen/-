//
//  CustomerDetailCellB.h
//  lianluozhongxin
//   客户管理-详情-业务信息
//  Created by sungoin-zjp on 15-7-4.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerDetailCellB : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewBusinessInfo;
@property (strong, nonatomic) IBOutlet UILabel *labelType;
@property (strong, nonatomic) IBOutlet UILabel *labelTypeName;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UILabel *labelTagKeyWords;
@property (strong, nonatomic) IBOutlet UILabel *labelKeyWords;

-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;
#pragma mark - 获取cell height
+(CGFloat)getCellContentHeight:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;

@end
