//
//  SitCell.h
//  
//
//  Created by sungoin-zjp on 16/1/5.
//
//

#import <UIKit/UIKit.h>

@interface SitCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelNo;
@property (strong, nonatomic) IBOutlet UILabel *lablePhone;
@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;


///填充详情
-(void)setCellDetail:(NSDictionary *)item;

@end
