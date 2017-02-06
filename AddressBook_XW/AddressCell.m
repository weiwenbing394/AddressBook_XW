//
//  AddressCell.m
//  AddressBook_XW
//
//  Created by 大家保 on 2017/2/6.
//  Copyright © 2017年 大家保. All rights reserved.
//

#import "AddressCell.h"

@implementation AddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.selectedBackgroundView=[UIView new];
    self.backgroundColor=[UIColor whiteColor];
    self.contentView.backgroundColor=[UIColor clearColor];
    self.textLabel.backgroundColor=[UIColor clearColor];
    self.detailTextLabel.backgroundColor=[UIColor clearColor];
}


@end
