//
//  StatusBarMsgView.h
//  IM 自定义消息提示
//
//  Created by sungoin-zjp on 16/3/23.
//
//

#import <UIKit/UIKit.h>

@interface StatusBarMsgView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;


@property (strong, nonatomic) IBOutlet UILabel *labelContent;



@end
