//
//  AddSitToNavigationCell.h
//  
//
//  Created by sungoin-zjp on 16/1/6.
//
//

#import <UIKit/UIKit.h>

@interface AddSitToNavigationCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *btnCheck;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelNo;
@property (strong, nonatomic) IBOutlet UILabel *labelPhone;

-(void)setCellDetail:(NSDictionary *)item;
///选择框事件
@property (nonatomic, copy) void (^CheckBoxBlock)(void);

@end
