//
//  EPFeedbackController.m
//  Elephrame
//
//  Created by folse on 7/15/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "EPFeedbackController.h"

@interface EPFeedbackController ()<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *contentTextView;

@end

@implementation EPFeedbackController

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
    
    [_contentTextView setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)feedbackButtonAction:(id)sender
{
    if (_contentTextView.text.length > 0) {
        
        [_contentTextView resignFirstResponder];
        
        [HUD show:YES];
        
        NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
        [parameterDict setObject:_contentTextView.text forKey:@"msg"];
        [parameterDict setObject:[USER_DEFAULTS valueForKeyPath:@"tokenId"] forKey:@"token"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager POST:API_FEEDBACK parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id JSON) {
            
            NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
            [HUD hide:YES];
            if ([[JSON valueForKey:@"code"] isEqualToString:@"1"]) {
                
                [HUD hide:YES];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提交成功" message:@"感谢您的宝贵建议" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                
            }else{
                
                NetWork_Error
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NetWork_Error
        }];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"我要吐个槽..."]) {
        [textView setText:@""];
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
