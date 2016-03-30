//
//  EditItemTypeCellRemarkEdit.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditItemModel;

@interface EditItemTypeCellRemarkEdit : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UITextView *textviewContent;





-(void)setCellDetail:(EditItemModel *)model;
@property (nonatomic, copy) void(^textValueChangedBlock) (NSString*);

@end
