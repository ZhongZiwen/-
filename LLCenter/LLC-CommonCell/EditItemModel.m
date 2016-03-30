//
//  EditItemModel.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditItemModel.h"

@implementation EditItemModel


- (NSDictionary *) encodedEditItemModel
{
    return [NSDictionary dictionaryWithObjectsAndKeys:self.title, @"title",self.content,@"content",self.placeholder,@"placeholder",self.cellType,@"cellType",nil];
}


@end
