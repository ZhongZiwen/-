//
//  DetailSegmentCell.h
//  shangketong
//  跟进记录  详细资料
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DetailSegmentDelegate;

@interface DetailSegmentCell : UITableViewCell

@property (assign, nonatomic) id <DetailSegmentDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIButton *btnRecord;
@property (strong, nonatomic) IBOutlet UIButton *btnInfos;


-(void)setCellFrame;
-(void)addClickEventForBtn;

///选择跟进记录或详细资料
@property (nonatomic, copy) void (^ChangeRecordOrDetailsBlock)(NSInteger position);

@end





@protocol DetailSegmentDelegate<NSObject>
@required
///点击跟进记录/详细资料
- (void)clickSegmentEvent:(NSInteger)tag;

@end