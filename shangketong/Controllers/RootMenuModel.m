//
//  RootMenuModel.m
//  shangketong
//
//  Created by sungoin-zjp on 15-12-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RootMenuModel.h"

@implementation RootMenuModel

//@{   @"image":@"menu_item_feed",
///@"title":@"工作圈",
///@"switch":@YES,
///@"group":@"groupA",
///@"eventIndex":@"1",
///@"unreadmsg",@"",
///@"tag","1"

- (RootMenuModel*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.menu_tag = [dict safeObjectForKey:@"tag"];
        self.menu_image = [dict safeObjectForKey:@"image"];
        self.menu_title = [dict safeObjectForKey:@"title"];
        self.menu_switch = [[dict objectForKey:@"switch"] boolValue];
        self.menu_group = [dict safeObjectForKey:@"group"];
        self.menu_eventindex = [dict safeObjectForKey:@"eventIndex"];
        self.menu_unreadmsg = [dict safeObjectForKey:@"unreadmsg"];
    }
    return self;
}

+ (RootMenuModel*)initWithDictionary:(NSDictionary *)dict {
    RootMenuModel *menuModel = [[RootMenuModel alloc] initWithDictionary:dict];
    return menuModel;
}


- (NSDictionary *) encodedEditItemModel
{
    return [NSDictionary dictionaryWithObjectsAndKeys:self.menu_image, @"menu_image",self.menu_title,@"menu_title",self.menu_switch,@"menu_switch",self.menu_tag,@"menu_tag",self.menu_group,@"menu_group",self.menu_eventindex,@"menu_eventindex",self.menu_unreadmsg,@"menu_unreadmsg",nil];
}


@end
