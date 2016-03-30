//
//  SearchResultCell.h
//  SearchItem
//
//  Created by 蒋 on 15/7/9.
//  Copyright (c) 2015年 蒋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultCell : UITableViewCell

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
//sales staff