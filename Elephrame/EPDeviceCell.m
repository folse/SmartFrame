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

- (void) setChecked:(BOOL)checked
{
	if (checked)
	{
		_checkImageView.image = [UIImage imageNamed:@"Selected"];
		self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
	}
	else
	{
		_checkImageView.image = nil;
		self.backgroundView.backgroundColor = [UIColor whiteColor];
	}
	_checked = checked;
}

@end
