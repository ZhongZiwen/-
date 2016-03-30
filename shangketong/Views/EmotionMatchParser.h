//
//  EmotionMatchParser.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

#define BEGIN_TAG @"["
#define END_TAG @"]"

#define kMatchParserString @"string"
#define kMatchParserRange @"range"
#define kMatchParserRects @"rects"
#define kMatchParserImage @"image"
#define kMatchParserLocation @"location"
#define kMatchParserLine @"line"

@interface EmotionMatchParser : NSObject

@property(nonatomic,strong) NSMutableAttributedString * attrString;
@property(nonatomic,strong) NSArray * images;

@property(nonatomic,strong) UIFont * font;

@property(nonatomic,strong) UIColor * textColor;

@property(nonatomic) float line;            //行距
@property(nonatomic) float paragraph;   // 段落间距
@property(nonatomic) float MutiHeight;  //多行行高
@property(nonatomic) float fristlineindent; // 首行缩进
@property(nonatomic) float iconSize;    // 表情Size
@property(nonatomic) float width;       // 宽度
@property(nonatomic) NSInteger numberOfLimitLines;   // 行数限定 (等于0 代表 行数不限)
@property(nonatomic,readonly) BOOL titleOnly;
@property(nonatomic,readonly) NSAttributedString * title;
@property(nonatomic,readonly) id ctFrame;
@property(nonatomic,readonly)float height;        // 总内容的高度
@property(nonatomic,readonly)float heightOflimit;   // 限定行数后的内容高度
@property(nonatomic,readonly)float miniWidth;       //只有一行时，内容宽度
@property(nonatomic,readonly)NSInteger numberOfTotalLines;         //内容行数
@property(nonatomic,readonly) NSString * source;      //原始内容

-(void)match:(NSString*)text;
-(void)buildFrames;
@end
