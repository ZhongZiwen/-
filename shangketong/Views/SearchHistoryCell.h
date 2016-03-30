//
//  SearchHistoryCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-6-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchHistoryCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelSearchStr;


-(void)setCellFrame;
-(void)setCellDetails:(NSDictionary *)item;

@end
