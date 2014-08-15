//
//  EPSuccessController.m
//  Elephrame
//
//  Created by Jennifer on 8/4/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "EPSuccessController.h"

@interface EPSuccessController ()

@end

@implementation EPSuccessController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)successButtonAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"afterSendPhoto" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_firstImage, @"sentPhoto", nil]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
