//
//  SitHeadCell.h
//  
//
//  Created by sungoin-zjp on 16/1/6.
//
//

#import <UIKit/UIKit.h>

@interface SitHeadCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelContent;
@property (strong, nonatomic) IBOutlet UIButton *btnRight;


-(void)setCellDetail:(NSDictionary *)item;

@property (nonatomic, copy) void (^RightBtnActionBlock)(void);

@end
