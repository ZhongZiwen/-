//
//  EmotionLabel.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EmotionLabel.h"
#import "EmotionMatchParser.h"

@implementation EmotionLabel

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.exclusiveTouch=YES;
    }
    return self;
}

- (void)setEmotionParser:(EmotionMatchParser *)emotionParser {
    if(emotionParser == _emotionParser)
        return;
    if (emotionParser.titleOnly) {
        self.attributed = NO;
        self.attributedText = emotionParser.attrString;
        [self setNeedsDisplay];
    }else{
        self.attributed = YES;
        _emotionParser = emotionParser;
        [self setNeedsDisplay];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if(!self.attributed){
        [super drawRect:rect];
        return;
    }
    if(self.emotionParser != nil && [self.emotionParser isKindOfClass:[EmotionMatchParser class]]){
        CGContextRef context = UIGraphicsGetCurrentContext();
        // Flip the coordinate system
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0, 10000);
        CGContextScaleCTM(context, 1.0, -1.0);
        if(self.emotionParser.numberOfLimitLines == 0 || (self.emotionParser.numberOfLimitLines>=self.emotionParser.numberOfTotalLines) || !self.linesLimit){
            CTFrameDraw((__bridge CTFrameRef)(self.emotionParser.ctFrame), context);
            for (NSDictionary* imageData in self.emotionParser.images) {
                NSString* img = [imageData objectForKey:kMatchParserImage];
                UIImage * image=[UIImage imageNamed:img];
                NSValue * value=[imageData objectForKey:kMatchParserRects];
                CGRect imgBounds;
                if(![value isKindOfClass:[NSNull class]])
                    imgBounds=[[imageData objectForKey:kMatchParserRects] CGRectValue];
                CGContextDrawImage(context, imgBounds, image.CGImage);
                
            }
        }
        else{
            NSArray *lines = (__bridge NSArray *)CTFrameGetLines((__bridge CTFrameRef)(self.emotionParser.ctFrame));
            CGPoint origins[[lines count]];
            CTFrameGetLineOrigins((__bridge CTFrameRef)(self.emotionParser.ctFrame), CFRangeMake(0, 0), origins); //2
            for(int lineIndex=0;lineIndex<self.emotionParser.numberOfLimitLines;lineIndex++){
                CTLineRef line=(__bridge CTLineRef)(lines[lineIndex]);
                CGContextSetTextPosition(context,origins[lineIndex].x,origins[lineIndex].y);
                //   NSLog(@"%d: %f,%f",lineIndex,origins[lineIndex].x,origins[lineIndex].y);
                CTLineDraw(line, context);
            }
            for (NSDictionary* imageData in self.emotionParser.images) {
                NSString* img = [imageData objectForKey:kMatchParserImage];
                UIImage * image=[UIImage imageNamed:img];
                NSValue * value=[imageData objectForKey:kMatchParserRects];
                CGRect imgBounds;
                if(![value isKindOfClass:[NSNull class]])
                {
                    imgBounds=[[imageData objectForKey:kMatchParserRects] CGRectValue];
                    NSNumber * number=[imageData objectForKey:kMatchParserLine];
                    int line=[number intValue];
                    if(line<self.emotionParser.numberOfLimitLines){
                        CGContextDrawImage(context, imgBounds, image.CGImage);
                    }
                }
            }
        }
    }
}
@end
