//
//  EPManageDeviceController.m
//  Elephrame
//
//  Created by folse on 7/16/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "EPManageDeviceController.h"
#import "EPDeviceCell.h"

@interface EPManageDeviceController ()
{
    NSMutableArray *deviceArray;
}

@end

@implementation EPManageDeviceController

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
    
    [self getDevice];
}

-(void)getDevice
{
    deviceArray = [USER_DEFAULTS objectForKey:@"deviceArray"];
    
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
    
    NSString *tokenId = [USER_DEFAULTS valueForKey:@"tokenId"];
    
    [parameterDict setObject:tokenId forKey:@"token"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:API_RELATION parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
        
        if ([[JSON valueForKey:@"code"] isEqualToString:@"1"]) {
            
            deviceArray = (NSMutableArray *)[JSON valueForKey:@"relations"];
            
            [USER_DEFAULTS setObject:deviceArray forKey:@"deviceArray"];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"获取相框信息失败" message:@"请稍后再试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (IBAction)menuButtonAction:(id)sender
{
    [self.view endEditing:YES];
    
    JDSideMenu *sideMenu = (JDSideMenu *)self.navigationController.parentViewController;
    
    if (sideMenu.isMenuVisible) {
        [sideMenu hideMenuAnimated:YES];
    }else{
        [sideMenu showMenuAnimated:YES];
    }
}

- (IBAction)editButtonAction:(id)sender
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if(self.tableView.editing){
        
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        
    }else{
        
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
    }
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
    
    EPDeviceCell *cell = (EPDeviceCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell.nameLabel setText:[NSString stringWithFormat:@"%@",deviceArray[row][@"name"]]];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        s(indexPath)
        
        [deviceArray removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationFade];
        
        //[self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
