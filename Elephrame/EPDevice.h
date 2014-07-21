//
//  EPDevice.h
//  Elephrame
//
//  Created by Jennifer on 7/21/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPDevice : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic) BOOL isChecked;

@end
