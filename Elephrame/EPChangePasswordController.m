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
            
            NSString *MANAGE_ACCOUNT = [NSString stringWithFormat:@"%@?token=%@&password=%@&old_password=%@",API_MANAGE_ACCOUNT,[USER_DEFAULTS valueForKeyPath:@"tokenId"],_setNewPasswordTextField.text,_currentPasswordTextField.text];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager POST:MANAGE_ACCOUNT parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
                NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
                [HUD hide:YES];
                if ([[JSON valueForKey:@"code"] isEqualToString:@"1"]) {
                    
                    [HUD hide:YES];
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"修改成功" delegate:self cancelButtonTitle:@"返回首页" otherButtonTitles:nil, nil];
                    [alertView show];
                    
                }else{
                    NetWork_Error
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NetWork_Error
            }];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"两次输入不一致" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
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
