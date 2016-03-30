//
//  IMAudioPlayView.h
//  IM消息  语音类型view
//
//  Created by sungoin-zjp on 16/2/18.
//
//

#import "AudioPlayView.h"

@interface IMAudioPlayView : AudioPlayView
@property (strong, nonatomic) NSNumber *second;
@property (nonatomic, copy) NSString *leftOrRight;

@property (nonatomic, assign) NSInteger index;
@end
