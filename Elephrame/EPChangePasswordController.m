//
//  EPChangePasswordController.m
//  Elephrame
//
//  Created by folse on 7/16/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "EPChangePasswordController.h"

@interface EPChangePasswordController ()
@property (strong, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *setNewPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *againNewPasswordTextField;

@end

@implementation EPChangePasswordController

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

- (IBAction)changePasswodButtonAction:(id)sender
{
    if (_currentPasswordTextField.text.length > 0 && _setNewPasswordTextField.text.length > 0 && _againNewPasswordTextField.text.length > 0) {
        
        if ([_setNewPasswordTextField.text isEqualToString:_againNewPasswordTextField.text]) {
            [self.view endEditing:YES];
            
            [HUD show:YES];
            
            NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
            [parameterDict setObject:_currentPasswordTextField.text forKey:@"old_password"];
            [parameterDict setObject:_setNewPasswordTextField.text forKey:@"password"];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager POST:API_MANAGE_ACCOUNT parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id JSON) {                
                NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
                [HUD hide:YES];
                if ([[JSON valueForKey:@"code"] isEqualToString:@"1"]) {
                    
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
