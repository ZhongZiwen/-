//
//  KnowledgeFileDetailsViewController.h
//  shangketong
//  文件详情
//  Created by sungoin-zjp on 15-5-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface KnowledgeFileDetailsViewController : UIViewController

///知识库  knowledge  其他 other
@property(strong,nonatomic)NSString *viewFrom;
@property(strong,nonatomic)NSDictionary *detailsOld;
@property(strong,nonatomic)NSMutableDictionary *details;
@property(assign,nonatomic)NSInteger indexRow;
@property (nonatomic, assign) BOOL isNeedRightNavBtn;

@property (strong, nonatomic) IBOutlet UIWebView *webView;



@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelSize;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UIButton *btnPreview;

@property (strong, nonatomic) IBOutlet UIView *viewProgress;
@property (strong, nonatomic) IBOutlet UIProgressView *progressview;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;

///更新收藏与未收藏的状态 根据action
@property (nonatomic, copy) void (^UpdateFavStatus)(NSInteger row, NSString *action);
///从服务器删除
@property (nonatomic, copy) void (^DeleteFileFromService)(void);

@property (nonatomic, copy) void (^DismissSearchViewBlock)(void);
@end
