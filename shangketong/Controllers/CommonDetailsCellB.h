//
//  CommonDetailsCellB.h
//  shangketong
//
//  Created by sungoin-zjp on 15-8-25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonDetailsCellB : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelContent;

@property (strong, nonatomic) IBOutlet UIButton *btnLeft;

@property (strong, nonatomic) IBOutlet UIImageView *imgLine;

@property (strong, nonatomic) IBOutlet UIButton *btnRight;


///填充详情
-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)index;


@property (nonatomic, copy) void (^DetailsLeftEventBlock)(NSInteger uid);
@property (nonatomic, copy) void (^DetailsRightEventBlock)(NSInteger uid);

@end
