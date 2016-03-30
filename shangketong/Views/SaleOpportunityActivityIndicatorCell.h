//
//  SaleOpportunityActivityIndicatorCell.h
//  shangketong
//  加载指示器
//  Created by sungoin-zjp on 15-6-25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaleOpportunityActivityIndicatorCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;


-(void)setCellFrame;

@end
