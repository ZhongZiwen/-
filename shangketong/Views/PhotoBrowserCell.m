//
//  PhotoBrowserCell.m
//  
//
//  Created by sungoin-zbs on 15/12/27.
//
//

#import "PhotoBrowserCell.h"
#import "Record.h"

@interface PhotoBrowserCell ()

@property (strong, nonatomic) UIImageView *mImageView;
@end

@implementation PhotoBrowserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.mImageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)configWithItem:(RecordImage *)item {
    _mImageView.image = item.thumbnailImage;
}

- (void)tapAction {
    if (self.imageTapBlock) {
        self.imageTapBlock();
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIImageView*)mImageView {
    if (!_mImageView) {
        _mImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _mImageView.userInteractionEnabled = YES;
        _mImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        _mImageView.transform = transform;
        _mImageView.frame = CGRectMake(0, 10, kScreen_Height, kScreen_Width);
    }
    return _mImageView;
}

@end
