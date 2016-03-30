//
//  ContactsInfo.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-24.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "ContactsInfo.h"
#import <objc/runtime.h>

@implementation ContactsInfo 

@synthesize userId,name,jobNumber,phoneNumber,departmentNameList,departmentIdList;

- (id)initWithDictionary:(NSDictionary*)dict {
    self.userId = [dict objectForKey:@"ID"];
    self.name = [dict objectForKey:@"name"];
    self.jobNumber = [dict objectForKey:@"jobNumber"];
    self.phoneNumber = [dict objectForKey:@"phoneNumber"];
    self.departmentNameList = [dict objectForKey:@"deptName"];
    self.departmentIdList = [dict objectForKey:@"deptId"];
    
    return self;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *dictionaryFormat = [NSMutableDictionary dictionary];
    //  取得当前类类型
    Class cls = [self class];
    
    unsigned int ivarsCnt = 0;
    //　获取类成员变量列表，ivarsCnt为类成员数量
    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
    
    //　遍历成员变量列表，其中每个变量都是Ivar类型的结构体
    for (const Ivar *p = ivars; p < ivars + ivarsCnt; ++p)
    {
        Ivar const ivar = *p;
        //　获取变量名
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        // 若此变量未在类结构体中声明而只声明为Property，则变量名加前缀 '_'下划线
        // 比如 @property(retain) NSString *abc;则 key == _abc;
        //　获取变量值
        id value = [self valueForKey:key];
        //　取得变量类型
        // 通过 type[0]可以判断其具体的内置类型
        //        const char *type = ivar_getTypeEncoding(ivar);
        if (value)
        {
            [dictionaryFormat setObject:value forKey:key];
        }
    }
    
    return dictionaryFormat;
}

@end
