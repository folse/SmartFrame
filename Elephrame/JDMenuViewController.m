//
//  JDMenuViewController.m
//  JDSideMenu
//
//  Created by Markus Emrich on 11.11.13.
//  Copyright (c) 2013 Markus Emrich. All rights reserved.
//

#import "UIViewController+JDSideMenu.h"
#import "JDMenuViewController.h"

@interface JDMenuViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation JDMenuViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

- (void)viewDidLayoutSubviews;
{
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = CGRectInset(self.scrollView.bounds, 0, -1).size;
}

- (IBAction)firstBtnAction:(id)sender
{
    UINavigationController *navController = [STORY_BOARD instantiateViewControllerWithIdentifier:@"mainNav"];
    [self.sideMenuController setContentController:navController animated:YES];
}

- (IBAction)secondBtnAction:(id)sender
{
    UINavigationController *navController = [STORY_BOARD instantiateViewControllerWithIdentifier:@"categoryNav"];
    [self.sideMenuController setContentController:navController animated:YES];
}

- (IBAction)thirdBtnAction:(id)sender
{
    UINavigationController *navController = [STORY_BOARD instantiateViewControllerWithIdentifier:@"feedbackNav"];
    [self.sideMenuController setContentController:navController animated:YES];
}

- (IBAction)fourthBtnAction:(id)sender
{
    UINavigationController *navController = [STORY_BOARD instantiateViewControllerWithIdentifier:@"settingsNav"];
    [self.sideMenuController setContentController:navController animated:YES];
}

@end
