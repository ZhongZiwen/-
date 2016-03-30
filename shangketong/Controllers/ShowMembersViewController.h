//
//  ShowMembersViewController.h
//  shangketong
//
//  Created by 蒋 on 15/8/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddressSelectMorePreModel;

@interface ShowMembersViewController : UIViewController

@property (nonatomic, strong) AddressSelectMorePreModel *memberModel;
@property (nonatomic, strong) NSMutableArray *membersArray;
@property (nonatomic, copy) void(^backMembersArrayBlock)(AddressSelectMorePreModel *model);
@property (nonatomic, assign) long long creataID; //接受传过来的创建人id
@end
