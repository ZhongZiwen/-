//
//  AddSitToNavigationCell.m
//  
//
//  Created by sungoin-zjp on 16/1/6.
//
//

#import "AddSitToNavigationCell.h"

@implementation AddSitToNavigationCell

- (void)awakeFromNib {
    // Initialization code
    self.labelName.frame = CGRectMake(15, 0, 90, 50);
    self.labelNo.frame = CGRectMake(115, 0, 50, 50);
    self.labelPhone.frame = CGRectMake(200, 0, kScreen_Width-180-60, 50);
    self.btnCheck.frame = CGRectMake(kScreen_Width-50, 0, 50, 50);
    self.btnCheck.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(NSDictionary *)item{
    NSString *name = [item safeObjectForKey:@"sitName"];
    NSString *no = [item safeObjectForKey:@"sitNo"];
    NSString *phone = [item safeObjectForKey:@"sitPhone"];
    
    
//    NSString *checkboxImg = @"";
//    if ([[item objectForKey:@"checked"] boolValue]) {
//        checkboxImg = @"login_checkbox_filled.png";
//    }else{
//        checkboxImg = @"login_checkbox_empty.png";
//    }
    
    
    self.accessoryType = UITableViewCellAccessoryNone;
   if ([[item objectForKey:@"checked"] boolValue]) {
        //        self.imgSelect.hidden = NO;
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    
//    [self.btnCheck setImage:[UIImage imageNamed:checkboxImg] forState:UIControlStateNormal];
    
    self.labelName.text = name;
    self.labelNo.text = no;
    self.labelPhone.text = phone;
    
    [self.btnCheck addTarget:self action:@selector(checkboxAction:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)checkboxAction:(id)sender{
    if (self.CheckBoxBlock) {
        self.CheckBoxBlock();
    }
}

@end
