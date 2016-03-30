//
//  DataDictionaryDetailCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
@interface DataDictionaryDetailCell : SWTableViewCell

@property (strong, nonatomic) IBOutlet UIButton *btnOption;

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;


@property (strong, nonatomic) IBOutlet UIButton *btnRemove;



-(void)setCellDetails:(NSDictionary *)item;
///设置左滑按钮
-(void)setLeftAndRightBtn;


///移除  设置默认
@property (nonatomic, copy) void (^InsertDefaultDictionaryBlock)(void);
@property (nonatomic, copy) void (^RemoveDefaultDictionaryBlock)(void);
@property (nonatomic, copy) void (^ShowRemoveBtnBlock)(void);
@end
