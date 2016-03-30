//
//  Directory.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Directory.h"

@implementation Directory

- (void)configFileTypeAndSize {
    NSString *extension = [_name pathExtension];
    if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"]) {
        _fileType = @"jpg";
    }
    else if ([extension isEqualToString:@"pdf"]) {
        _fileType = @"pdf";
        _fileIcon = @"pdf";
    }
    else if ([extension isEqualToString:@"txt"]) {
        _fileType = @"txt";
        _fileIcon = @"txt";
    }
    else if ([extension isEqualToString:@"zip"]) {
        _fileType = @"zip";
        _fileIcon = @"zip";
    }
    else if ([extension isEqualToString:@"doc"] || [extension isEqualToString:@"docx"]) {
        _fileType = @"doc";
        _fileIcon = @"doc";
    }
    else if ([extension isEqualToString:@"pages"]) {
        _fileType = @"pages";
        _fileIcon = @"doc";
    }
    else if ([extension isEqualToString:@"ppt"] || [extension isEqualToString:@"pptx"]) {
        _fileType = @"ppt";
        _fileIcon = @"ppt";
    }
    else if ([extension isEqualToString:@"key"]) {
        _fileType = @"key";
        _fileIcon = @"ppt";
    }
    else if ([extension isEqualToString:@"xls"] || [extension isEqualToString:@"xlsx"]) {
        _fileType = @"xls";
        _fileIcon = @"xls";
    }
    else if ([extension isEqualToString:@"numbers"]) {
        _fileType = @"numbers";
        _fileIcon = @"xls";
    }
    else if ([extension isEqualToString:@"mp4"]) {
        _fileType = @"movie";
        _fileIcon = @"movie";
    }
    else if ([extension isEqualToString:@"mp3"]) {
        _fileType = @"music";
        _fileIcon = @"music";
    }
    else if ([extension isEqualToString:@"md"]) {
        _fileType = @"md";
        _fileIcon = @"md";
    }
    else if ([extension isEqualToString:@"html"]) {
        _fileType = @"html";
        _fileIcon = @"code";
    }
    else if ([extension isEqualToString:@"plist"]) {
        _fileType = @"plist";
        _fileIcon = @"unknown";
    }
    else {
        _fileType = @"unknown";
        _fileIcon = @"unknown";
    }
    
    _fileSize = [NSString sizeDisplayWithByte:[_size floatValue]];
}
@end
