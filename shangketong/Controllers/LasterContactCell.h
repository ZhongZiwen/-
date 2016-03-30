//
//  LasterContactCell.h
//  shangketong
//
//  Created by 蒋 on 15/9/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressBook.h"
@interface LasterContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *oneBtn;
@property (weak, nonatomic) IBOutlet UILabel *oneLable;
@property (weak, nonatomic) IBOutlet UIButton *twoBtn;
@property (weak, nonatomic) IBOutlet UILabel *twoLabel;
@property (weak, nonatomic) IBOutlet UIButton *threeBtn;
@property (weak, nonatomic) IBOutlet UILabel *threeLabel;
@property (weak, nonatomic) IBOutlet UIButton *fourBtn;
@property (weak, nonatomic) IBOutlet UILabel *fourLabel;
@property (weak, nonatomic) IBOutlet UIButton *fiveBtn;
@property (weak, nonatomic) IBOutlet UILabel *fiveLabel;

@property (nonatomic, copy) void(^BackContactIDBlock)(NSInteger userID);
@property (nonatomic, strong) AddressBook *item;
@property (nonatomic, strong) NSMutableArray *contactArray;
- (void)setValueForCell:(NSArray *)array;
@end
