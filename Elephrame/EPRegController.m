//
//  EPRegController.m
//  Elephrame
//
//  Created by folse on 7/14/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "EPRegController.h"

@interface EPRegController ()

@property (strong, nonatomic) IBOutlet UITextField *mobileTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation EPRegController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)regButtonAction:(id)sender
{    
    if (_mobileTextField.text.length > 0 && _passwordTextField.text.length > 0 && _emailTextField.text.length > 0) {
        
        [self.view endEditing:YES];
        
        [HUD show:YES];
        
        NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
        [parameterDict setObject:_mobileTextField.text forKey:@"tel"];
        [parameterDict setObject:_passwordTextField.text forKey:@"password"];
        [parameterDict setObject:_emailTextField.text forKey:@"email"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager POST:API_REG parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id JSON) {
            
            NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
            [HUD hide:YES];
            if ([[JSON valueForKey:@"code"] isEqualToString:@"1"]) {
                
                [MobClick event:@"Success_Login"];
                NSDictionary *data = (NSDictionary *)[JSON valueForKey:@"data"];
                
                NSString *tokenId = [data valueForKey:@"token"];
                
                saveValue(tokenId, @"tokenId")
                saveValue(_mobileTextField.text, @"userMobile");
                [USER_DEFAULTS setBool:YES forKey:@"userLogined"];
                
                [HUD hide:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
                return ;
                
            }else{
                NetWork_Error
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NetWork_Error
        }];
    }
}

#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
