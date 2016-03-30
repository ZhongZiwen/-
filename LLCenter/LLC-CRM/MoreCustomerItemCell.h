//
//  MoreCustomerItemCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-7-6.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BtnNameClickDelegate;

@interface MoreCustomerItemCell : UITableViewCell

@property (assign, nonatomic) id <BtnNameClickDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIButton *btnName;
@property (assign, nonatomic) NSInteger index;

@property (nonatomic,copy) void (^BtnSingleTapBlock)(NSInteger index);

-(void)setCellDetails:(NSString *)name indexPath:(NSIndexPath *)indexPath;


//block
typedef void (^BtnItemClickBlock)(NSInteger index);
@property (nonatomic, copy) BtnItemClickBlock btnItemClickBlock;
- (void)itemClick:(BtnItemClickBlock)block;

@end


@protocol BtnNameClickDelegate<NSObject>
@required

///btn点击事件
- (void)btnNameClickEvent:(NSInteger)index;

@end
