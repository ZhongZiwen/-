//
//  ClueHighSeaPoolGroupDetailCell.h
//  shangketong
//  线索公海池
//  Created by sungoin-zjp on 15-6-3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ClueHighSeaPoolGroupDetailDelegate;

@interface ClueHighSeaPoolGroupDetailCell : UITableViewCell

@property (assign, nonatomic) id <ClueHighSeaPoolGroupDetailDelegate>delegate;

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelCompName;
///日期 + 创建 +退回次数
@property (strong, nonatomic) IBOutlet UILabel *labelInfos;
@property (strong, nonatomic) IBOutlet UIButton *btnGet;


-(void)setCellFrame;
-(void)setCellContentDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;
@end


@protocol ClueHighSeaPoolGroupDetailDelegate<NSObject>
@required

///点击领取事件
- (void)clickGetEvent:(NSInteger)index;

@end
