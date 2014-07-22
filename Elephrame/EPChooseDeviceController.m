//
//  EPChooseDeviceController.m
//  Elephrame
//
//  Created by Jennifer on 7/15/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "EPChooseDeviceController.h"
#import "EPDeviceCell.h"
#import "EPDevice.h"

@interface EPChooseDeviceController ()
{
    NSInteger selectedId;
    NSMutableArray *deviceArray;
    NSMutableArray *selectedDeviceArray;
}

@end

@implementation EPChooseDeviceController

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
    
    deviceArray = [NSMutableArray new];
    selectedDeviceArray = [NSMutableArray new];
    
    NSArray *deviceDataArray = [USER_DEFAULTS objectForKey:@"deviceArray"];
    
    for (int i = 0; i < deviceDataArray.count; i++) {
        EPDevice *device = [[EPDevice alloc] init];
        device.name = deviceDataArray[i][@"name"];
        device.isChecked = NO;
        [deviceArray addObject:device];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    EPDevice *cellDevice = [deviceArray objectAtIndex:row];
    
    EPDeviceCell *cell = (EPDeviceCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell.nameLabel setText:cellDevice.name];
	[cell setChecked:cellDevice.isChecked];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPDevice *selectedDevice = [deviceArray objectAtIndex:indexPath.row];
	   
    EPDeviceCell *cell = (EPDeviceCell*)[tableView cellForRowAtIndexPath:indexPath];
    selectedDevice.isChecked = !selectedDevice.isChecked;
    [cell setChecked:selectedDevice.isChecked];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)doneButtonAction:(id)sender
{
    for (int i = 0; i < deviceArray.count; i++) {
        
        if ([deviceArray[i] isChecked]) {
            [selectedDeviceArray addObject:deviceArray[i][@"frameid"]];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"afterChooseDevice" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:selectedDeviceArray, @"deviceArray", nil]];
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
