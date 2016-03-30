//
//  MsgSelectedContactOrCustomerViewController.h
//  shangketong
//  已选择的客户/联系人
//  Created by sungoin-zjp on 15-6-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MsgSelectedContactDelegate;

@interface MsgSelectedContactOrCustomerViewController : UIViewController
@property (assign, nonatomic) id <MsgSelectedContactDelegate>delegate;

@property(strong,nonatomic) UITableView *tableviewSelected;
@property(strong,nonatomic)NSArray *arrayAllContact;

///类型  contact / customer
@property(strong,nonatomic)NSString *typeContact;

@end


@protocol MsgSelectedContactDelegate<NSObject>
@required
///更新已选中的联系人
- (void)notifySelectedArray:(NSArray *)selectedArr;
@end