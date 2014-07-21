//
//  EPDeviceCell.h
//  Elephrame
//
//  Created by Jennifer on 7/19/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPDeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (nonatomic) BOOL checked;

- (void) setChecked:(BOOL)checked;

@end
