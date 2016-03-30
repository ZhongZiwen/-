//
//  HomeSearchResultCell.h
//  
//
//  Created by sungoin-zjp on 16/1/15.
//
//

#import <UIKit/UIKit.h>

@interface HomeSearchResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *viewContentBg;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;

@property (weak, nonatomic) IBOutlet UILabel *labelRowTitle1;
@property (weak, nonatomic) IBOutlet UILabel *labelRowValue1;

@property (weak, nonatomic) IBOutlet UILabel *labelRowTitle2;
@property (weak, nonatomic) IBOutlet UILabel *labelRowValue2;

@property (weak, nonatomic) IBOutlet UILabel *labelRowTitle3;
@property (weak, nonatomic) IBOutlet UILabel *labelRowValue3;

///根据不同数据类型的cell  传入type 以作区分标记
-(void)setCellDetails:(NSDictionary *)item byCellType:(NSString *)cellType;

@end
