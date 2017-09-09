//
//  XBMCouponProCell.m
//  excelRever
//
//  Created by 胥佰淼 on 2016/11/13.
//  Copyright © 2016年 胥佰淼. All rights reserved.
//

#import "XBMCouponProCell.h"
#import "XBMProductModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface XBMCouponProCell ()

@property (weak, nonatomic) IBOutlet UIImageView *proImageView;
@property (weak, nonatomic) IBOutlet UILabel *proNameLB;
@property (nonatomic, strong) XBMProductModel *model;
@property (weak, nonatomic) IBOutlet UILabel *proPriceLB;
@property (weak, nonatomic) IBOutlet UILabel *proCouponInfoLB;


@end

@implementation XBMCouponProCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellAccessoryNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfoSHow:(id)model {
    self.model = model;
    self.proNameLB.text = self.model.proName;
    [self.proImageView sd_setImageWithURL:[NSURL URLWithString:self.model.imgUrl]];
    self.proPriceLB.text = [NSString stringWithFormat:@"原价：%@元", self.model.price];
    self.proCouponInfoLB.text = self.model.proCouponInfo;
}

+ (CGFloat)cellHeight:(id)model {
    NSString *str = ((XBMProductModel *)model).proName;
    CGFloat height = 73;
    if (str) {
        height += ceilf([str boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 135, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.0] } context:nil].size.height);
        
    }
    
    return height > 117 ? height : 117;
}

@end
