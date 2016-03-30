//
//  BasicPreviewItem.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/31.
//  Copyright © 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface BasicPreviewItem : NSObject<QLPreviewItem>

+ (BasicPreviewItem*)itemWithUrl:(NSURL*)itemUrl;
- (instancetype)initWithUrl:(NSURL*)itemUrl title:(NSString*)title;
@end
