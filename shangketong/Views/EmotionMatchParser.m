//
//  EmotionMatchParser.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EmotionMatchParser.h"

static CGFloat ascentCallback( void *ref ){
    return 0;
}
static CGFloat descentCallback( void *ref ){
    return 0;
}
static CGFloat widthCallback( void* ref ){
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}

@implementation EmotionMatchParser
@synthesize attrString,images,font,textColor,iconSize,ctFrame=_ctFrame,height=_height,width,line,paragraph,source=_source,miniWidth=_miniWidth,numberOfTotalLines=_numberOfTotalLines,heightOflimit=_heightOflimit;

-(id)init
{
    self=[super init];
    if(self){
        self.font=[UIFont systemFontOfSize:14];
        self.textColor=[UIColor blackColor];
        self.iconSize=20.0f;
        self.line=5.0f;
        self.paragraph=5.0f;
        self.MutiHeight=18.0f;
        self.fristlineindent=5.0f;
    }
    return self;
}

+(NSDictionary*)getFaceMap
{
    static NSDictionary * dic=nil;
    if(dic==nil){
        NSString* path=[[NSBundle mainBundle] pathForResource:@"emotionImage" ofType:@"plist"];
        dic =[NSDictionary dictionaryWithContentsOfFile:path];
    }
    return dic;
}

+(NSString*)valueForKey:(NSString*)key map:(NSDictionary*) map
{
    NSString *value = [map objectForKey:key];
    return value;
}

-(void)match:(NSString*)source
{
    if (source==nil) {
        return;
    }
    _source=source;
    NSMutableString * text=[[NSMutableString alloc]init];
    NSMutableArray * imageArr=[[NSMutableArray alloc]init];
    NSRegularExpression * regular=[[NSRegularExpression alloc]initWithPattern:@"\\[[^\\[\\]\\s]+\\]" options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionCaseInsensitive error:nil];
    NSArray * array=[regular matchesInString:source options:0 range:NSMakeRange(0, [source length])];
    
    NSInteger location=0;
    NSInteger count=[array count];
    for(int i=0;i<count;i++){
        NSTextCheckingResult * result=[array objectAtIndex:i];
        NSString * string=[source substringWithRange:result.range];
        NSString * icon=[EmotionMatchParser valueForKey:string map:[EmotionMatchParser getFaceMap]];
        [text appendString:[source substringWithRange:NSMakeRange(location, result.range.location-location)]];
        if(icon!=nil){
            NSMutableString * iconStr=[NSMutableString stringWithFormat:@"%@.png",icon];
            NSMutableDictionary * dic=[NSMutableDictionary dictionaryWithObjectsAndKeys:iconStr,kMatchParserImage,[NSNumber numberWithInteger:[text length]],kMatchParserLocation,[NSNull null],kMatchParserRects, nil];
            [imageArr addObject:dic];
            [text appendString:@" "];
        }else{
            [text appendString:string];
        }
        location=result.range.location+result.range.length;
    }
    [text appendString:[source substringWithRange:NSMakeRange(location, [source length]-location)]];
    CTFontRef fontRef=CTFontCreateWithName((__bridge CFStringRef)(self.font.fontName),self.font.pointSize,NULL);
    NSDictionary *attribute=[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef,kCTFontAttributeName,(id)self.textColor.CGColor,kCTForegroundColorAttributeName,nil];
    NSMutableAttributedString * attStr=[[NSMutableAttributedString alloc]initWithString:text attributes:attribute];
    
    for(NSDictionary * dic in imageArr){
        NSInteger location= [[dic objectForKey:kMatchParserLocation] integerValue];
        CTRunDelegateCallbacks callbacks;
        callbacks.version = kCTRunDelegateVersion1;
        callbacks.getAscent = ascentCallback;
        callbacks.getWidth = widthCallback;
        callbacks.getDescent=descentCallback;
        
        NSDictionary* imgAttr = [NSDictionary dictionaryWithObjectsAndKeys: //2
                                 [NSNumber numberWithFloat:(self.iconSize+2)], @"width",
                                 nil] ;
        CTRunDelegateRef delegate=CTRunDelegateCreate(&callbacks, (__bridge void *)(imgAttr));
        NSDictionary* attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:
                                                //set the delegate
                                                (__bridge id)delegate, (NSString*)kCTRunDelegateAttributeName,
                                                nil];
        
        [attStr addAttributes:attrDictionaryDelegate range:NSMakeRange(location, 1)];
    }
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    
    
    CGFloat lineSpace=self.line;//间距数据
    CTParagraphStyleSetting lineSpaceStyle;
    lineSpaceStyle.spec=kCTParagraphStyleSpecifierLineSpacing;
    lineSpaceStyle.valueSize=sizeof(lineSpace);
    lineSpaceStyle.value=&lineSpace;
    
    //设置  段落间距
    CGFloat paragraphs = self.paragraph;
    CTParagraphStyleSetting paragraphStyle;
    paragraphStyle.spec = kCTParagraphStyleSpecifierParagraphSpacing;
    paragraphStyle.valueSize = sizeof(CGFloat);
    paragraphStyle.value = &paragraphs;
    
    //创建样式数组
    CTParagraphStyleSetting settings[] = {
        lineBreakMode,lineSpaceStyle,paragraphStyle
    };
    
    //设置样式
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 3);
    
    
    // build attributes
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(__bridge id)style forKey:(id)kCTParagraphStyleAttributeName ];
    [attStr addAttributes:attributes range:NSMakeRange(0, [text length])];
    CFRelease(fontRef);
    CFRelease(style);
    self.attrString=attStr;
    self.images=imageArr;
    [self buildFrames];
    
}

#pragma -mark 私有方法

-(void)buildFrames
{
    CGMutablePathRef path = CGPathCreateMutable(); //2
    CGRect textFrame = CGRectMake(0,0, width, 10000);
    CGPathAddRect(path, NULL, textFrame );
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attrString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attrString length]), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame); //1
    NSInteger count=[lines count];
    CGPoint *origins=alloca(sizeof(CGPoint)*count);
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins); //2
    
#pragma -mark 获得内容的总高度
    //获得内容的总高度
    if([lines count]>=1){
        float line_y = (float) origins[[lines count] -1].y;  //最后一行line的原点y坐标
        CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        CTLineRef line1 = (__bridge CTLineRef) [lines lastObject];
        CTLineGetTypographicBounds(line1, &ascent, &descent, &leading);
        float total_height =10000- line_y + descent+1 ;    //+1为了纠正descent转换成int小数点后舍去的值
        _height=total_height+2;
    }else{
        _height=0;
    }
    
    lines = (__bridge NSArray *)CTFrameGetLines(frame); //1
    CGPoint *Origins=alloca(sizeof(CGPoint)*count);
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), Origins); //2
    
#pragma -mark 获取内容行数 以及 一行时，内容的宽度
    // 获取内容行数 以及 一行时，内容的宽度
    _numberOfTotalLines=[lines count];
    if(_numberOfTotalLines>1){
        _miniWidth=self.width;
    }else{
        CTLineRef lineOne=(__bridge CTLineRef)lines[0];
        _miniWidth=CTLineGetTypographicBounds(lineOne, nil, nil, nil);
    }
    
#pragma -mark 获取限定行数后内容的高度
    //  获取限定行数后内容的高度
    if(_numberOfTotalLines<=_numberOfLimitLines||_numberOfLimitLines==0){
        _heightOflimit=_height;
    }else{
        CTLineRef line1=(__bridge CTLineRef)(lines[_numberOfLimitLines-1]);
        float line_y = (float) origins[_numberOfLimitLines -1].y;  //最后一行line的原点y坐标
        CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        CTLineGetTypographicBounds(line1, &ascent, &descent, &leading);
        float total_height =10000- line_y + descent+1 ;    //+1为了纠正descent转换成int小数点后舍去的值
        _heightOflimit=total_height+2;
    }
    
    
#pragma -mark  解析表情图片
    // 解析表情图片
    if([self.images count]>0){
        int imgIndex = 0; //3
        NSDictionary* nextImage = [self.images objectAtIndex:imgIndex];
        NSInteger imgLocation =[[nextImage objectForKey:kMatchParserLocation] integerValue];
        NSInteger lineIndex = 0;
        for (id lineObj in lines) { //5
            CTLineRef line1 = (__bridge CTLineRef)lineObj;
            for (id runObj in (__bridge NSArray *)CTLineGetGlyphRuns(line1)) { //6
                CTRunRef run = (__bridge CTRunRef)runObj;
                CFRange runRange = CTRunGetStringRange(run);
                if ( runRange.location==imgLocation) { //7
                    CGRect runBounds;
                    runBounds.size.width =iconSize; //8
                    runBounds.size.height =iconSize;
                    
                    CGPoint *point=alloca(sizeof(CGPoint));
                    CTRunGetPositions(run, CFRangeMake(0, 0), point);
                    runBounds.origin.x = (*point).x+Origins[lineIndex].x+1;
                    runBounds.origin.y = (*point).y-4+Origins[lineIndex].y;
                    
                    //      NSLog(@"poing x: %f, y:%f",point.x,point.y);
                    NSMutableDictionary * dic=[self.images objectAtIndex:imgIndex];
                    [dic setObject:[NSValue valueWithCGRect:runBounds] forKey:kMatchParserRects];
                    [dic setObject:[NSNumber numberWithInteger:lineIndex] forKey:kMatchParserLine];
                    //load the next image //12
                    
                    imgIndex++;
                    if (imgIndex < [self.images count]) {
                        nextImage = [self.images objectAtIndex: imgIndex];
                        imgLocation =[[nextImage objectForKey:kMatchParserLocation] integerValue];
                    }else{
                        lineIndex=[lines count];
                        break;
                    }
                }
            }
            if(lineIndex>=[lines count])
                break;
            lineIndex++;
        }
    }
    _ctFrame=(__bridge id)frame;
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}
@end
