//
//  RootMenuModel.h
//  shangketong
//
//  Created by sungoin-zjp on 15-12-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RootMenuModel : NSObject

//@{   @"image":@"menu_item_feed",
///@"title":@"工作圈",
///@"switch":@YES,
///@"group":@"groupA",
///@"eventIndex":@"1",
///@"unreadmsg",@"",
///@"tag","1"

@property(nonatomic,strong) NSString *menu_tag;
@property(nonatomic,strong) NSString *menu_image;
@property(nonatomic,strong) NSString *menu_title;
@property(nonatomic,assign) BOOL menu_switch;
@property(nonatomic,strong) NSString *menu_group;
@property(nonatomic,strong) NSString *menu_eventindex;
@property(nonatomic,strong) NSString *menu_unreadmsg;



- (RootMenuModel*)initWithDictionary:(NSDictionary *)dict;
+ (RootMenuModel*)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *) encodedEditItemModel;
@end
