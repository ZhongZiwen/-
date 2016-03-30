//
//  SheetmenuCellB.h
//  shangketong
//  cell 类型B
//  Created by sungoin-zjp on 15-6-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetMenuModel.h"

@protocol CallPhoneOrSendMsgDelegate;

@interface SheetmenuCellB : UITableViewCell

@property (assign, nonatomic) id <CallPhoneOrSendMsgDelegate>delegate;

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnLeft;
@property (strong, nonatomic) IBOutlet UIButton *btnRight;


-(void)setCellFrame;
-(void)setCellDetails:(SheetMenuModel *)item indexPath:(NSIndexPath *)indexPath;

@end


@protocol CallPhoneOrSendMsgDelegate<NSObject>
@required
///点击拨号事件
- (void)clickCallPhoneEvent:(NSInteger)index;
///点击发短信事件
-(void)clickSendMsgEvent:(NSInteger)index;
@end
