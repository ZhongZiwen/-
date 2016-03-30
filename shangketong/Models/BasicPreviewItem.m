//
//  BasicPreviewItem.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/31.
//  Copyright © 2015年 sungoin. All rights reserved.
//

#import "BasicPreviewItem.h"

@implementation BasicPreviewItem
@synthesize previewItemTitle = _previewItemTitle;
@synthesize previewItemURL   = _previewItemURL;

- (void)dealloc {
    _previewItemTitle = nil;
    _previewItemURL = nil;
}

+ (BasicPreviewItem*)itemWithUrl:(NSURL *)itemUrl {
    if (!itemUrl) {
        return nil;
    }
    
    NSString *itemTitle = itemUrl.absoluteString;
    itemTitle = [itemTitle stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    itemTitle = [[itemTitle componentsSeparatedByString:@"/"] lastObject];
    itemTitle = [[itemTitle componentsSeparatedByString:@"|||"] firstObject];
    return [[BasicPreviewItem alloc] initWithUrl:itemUrl title:itemTitle];
}

- (instancetype)initWithUrl:(NSURL *)itemUrl title:(NSString *)title{
    self = [super init];
    if (self) {
        _previewItemURL = itemUrl;
        _previewItemTitle = title;
    }
    return self;
}
@end
