//
//  WorkGroupPraiseListCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-7-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PraiseContactDelegate;

@interface WorkGroupPraiseListCell : UITableViewCell

@property (assign, nonatomic) id <PraiseContactDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITableView *tableviewPraise;

@property(strong,nonatomic) NSArray *arrayPraise;

-(void)setCellDetails:(NSArray *)array indexPath:(NSIndexPath *)indexPath;
@end


@protocol PraiseContactDelegate<NSObject>
@required
///点击赞user头像事件
- (void)clickPraiseUserIconEvent:(NSInteger)row;

@end