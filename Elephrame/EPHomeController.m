//
//  EPHomeController.m
//  Elephrame
//
//  Created by Jennifer on 7/15/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "EPHomeController.h"
#import "CTAssetsPickerController.h"

@interface EPHomeController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *addAssets;

@end

@implementation EPHomeController
{
    BOOL isFromCamera;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self getDevice];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getDevice
{
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
    [parameterDict setObject:[USER_DEFAULTS valueForKey:@"tokenId"] forKey:@"token"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:API_RELATION parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
        
        if ([[JSON valueForKey:@"code"] isEqualToString:@"1"]) {
            
            NSArray *relationDevices = (NSArray *)[JSON valueForKey:@"relations"];
            
            [USER_DEFAULTS setObject:relationDevices forKey:@"devicesArray"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (IBAction)menuButtonAction:(id)sender
{
    JDSideMenu *sideMenu = (JDSideMenu *)self.navigationController.parentViewController;
    
    if (sideMenu.isMenuVisible) {
        [sideMenu hideMenuAnimated:YES];
    }else{
        [sideMenu showMenuAnimated:YES];
    }
}

- (IBAction)cameraButtonAction:(id)sender
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)albumButtonAction:(id)sender
{
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection = 10 - [self.assets count];
    picker.navigationController.navigationItem.title = @"选取照片";
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate -
#pragma mark  From Camera Image

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
        isFromCamera = YES;
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
    isFromCamera = NO;
    uploadId = 0;
    ALAsset *asset = assets[uploadId];
    UIImage *assetOriImage =[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];

    [self finishChooseImage:assetOriImage];
}

-(void)finishChooseImage:(UIImage *)image
{
    NSArray *deviceArray = [USER_DEFAULTS objectForKey:@"devicesArray"];
    
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
