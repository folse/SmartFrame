//
//  EPDeviceCell.m
//  Elephrame
//
//  Created by Jennifer on 7/19/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "EPDeviceCell.h"

@implementation EPDeviceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
