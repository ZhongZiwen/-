//
//  MenuItemSwitchCell.m
//  
//
//  Created by sungoin-zjp on 16/1/20.
//
//

#import "MenuItemSwitchCell.h"
#import "NSUserDefaults_Cache.h"

@implementation MenuItemSwitchCell

- (void)awakeFromNib {
    // Initialization code
    self.lableTitle.frame = CGRectMake(15, 0, kScreen_Width-90, 45);
    self.switchBtn.frame = CGRectMake(kScreen_Width-71, 6, 51, 31);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetail:(NSDictionary *)item{
    self.lableTitle.text = [item safeObjectForKey:@"title"];
    [self.switchBtn setOn:NO];
    if ([[item safeObjectForKey:@"eventIndex"] integerValue] == 7) {
        ///消息开关
        if([NSUserDefaults_Cache getIMMessageStatu]){
            [self.switchBtn setOn:YES];
        }
    }else{
        ///消息声音开关
        if([NSUserDefaults_Cache getIMMessageStatuVoice]){
            [self.switchBtn setOn:YES];
        }
    }
    
    self.switchBtn.tag = [[item safeObjectForKey:@"eventIndex"] integerValue];
    [self.switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)switchAction:(id)sender {
    
    UISwitch *switchButton = (UISwitch*)sender;
    Boolean isOn = switchButton.isOn;
    NSInteger tag = switchButton.tag;
    
    if (tag == 7) {
        [NSUserDefaults_Cache setIMMessageStatus:isOn];
    }else if (tag == 8){
        [NSUserDefaults_Cache setIMMessageVoiceStatus:isOn];
    }
    if (self.NotifySwitchBlock) {
        self.NotifySwitchBlock();
    }
}
@end
