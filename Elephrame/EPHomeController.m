//
//  EPHomeController.m
//  Elephrame
//
//  Created by Jennifer on 7/15/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "EPHomeController.h"
#import "CTAssetsPickerController.h"
#import "EPChooseDeviceController.h"

@interface EPHomeController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate>
{
    NSMutableArray *deviceArray;
}

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *addAssets;

@end

@implementation EPHomeController
{
    int uploadId;
    BOOL isFinishUploadImage;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!USER_LOGIN) {
   
        UINavigationController *regNavController = [STORY_BOARD instantiateViewControllerWithIdentifier:@"regNav"];
        
        [self presentViewController:regNavController animated:YES completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    deviceArray = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadImageToDevice:) name:@"afterChooseDevice" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

-(void)uploadImageToDevice:(NSString *)deviceId
{
    s(deviceId)
    
        
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

- (IBAction)cameraButtonAction:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:controller animated:YES completion:^{
            
            [[[NSThread alloc] initWithTarget:self selector:@selector(getDevice) object:nil] start];
        }];
    }
}

- (IBAction)albumButtonAction:(id)sender
{
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection = 10 - [self.assets count];
    picker.navigationController.navigationItem.title = @"选取照片";
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        
        [[[NSThread alloc] initWithTarget:self selector:@selector(getDevice) object:nil] start];
    }];
}

#pragma mark - UIImagePickerControllerDelegate -
#pragma mark  From Camera Image

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [self.assets addObject:info[UIImagePickerControllerOriginalImage]];
        [self finishChooseImage:info[UIImagePickerControllerOriginalImage]];
    }];
}

#pragma mark Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (![assets count]) return;
    [self.addAssets removeAllObjects];
    [self.assets addObjectsFromArray:assets];
    [self.addAssets addObjectsFromArray:assets];
    uploadId = 0;
    ALAsset *asset = assets[uploadId];
    UIImage *assetOriImage =[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];

    [self finishChooseImage:assetOriImage];
}

-(void)finishChooseImage:(UIImage *)image
{    
    if (deviceArray.count == 1) {
        
    }else{
        [self performSegueWithIdentifier:@"ChooseDeviceController" sender:self];
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
