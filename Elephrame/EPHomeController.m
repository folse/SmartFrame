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
    NSArray *deviceArray;
}

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

//-(void)viewDidAppear:(BOOL)animated
//{
//    if (!USER_LOGIN || [USER_DEFAULTS boolForKey:@"timeout"]) {
//        
//        GuideController *guideVC = [GuideController new];
//        [self presentViewController:guideVC animated:YES completion:^{
//            if([USER_DEFAULTS boolForKey:@"timeout"]){
//                [(UIPageControl *)VIEWWITHTAG(guideVC.view, 1012) setCurrentPage:4];
//                [(SWParallaxScrollView *)VIEWWITHTAG(guideVC.view, 1011) setContentOffset:CGPointMake(SCREEN_WIDTH * 4, 0) animated:NO];
//            }
//        }];
//        return;
//    }
//    
//    if (USER_LOGIN && !MORE_THAN_FIRST_LOAD) {
//        CGPoint point = CGPointMake(-1000, -1000);
//        [MLPSpotlight addSpotlightInView:self.view atPoint:point];
//        guideImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mask_slidescreen"]];
//        [guideImageView setFrame:CGRectMake(0, SCREEN_HEIGHT - guideImageView.frame.size.height, 300, 310)];
//        guideImageView.center = CGPointMake(SCREEN_WIDTH/2, guideImageView.frame.origin.y);
//        guideImageView.userInteractionEnabled = YES;
//        [self.view addSubview:guideImageView];
//        [self addGestureRecognizerOnMLPSpotlight];
//        [USER_DEFAULTS setBool:YES forKey:@"moreThanFirstLoad"];
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //[self getDevice];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(uploadImageToDevice:) name:@"afterChooseDevice" object:nil];
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
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
    [parameterDict setObject:[USER_DEFAULTS valueForKey:@"tokenId"] forKey:@"token"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:API_RELATION parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
        
        if ([[JSON valueForKey:@"code"] isEqualToString:@"1"]) {
            
            NSArray *relationDevices = (NSArray *)[JSON valueForKey:@"relations"];
            
            [USER_DEFAULTS setObject:relationDevices forKey:@"devicesArray"];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"获取相框信息失败" message:@"请稍后再试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)uploadImageToDevice:(NSString *)deviceId
{
    
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
        [self presentViewController:controller animated:YES completion:nil];
    }
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
    deviceArray = [USER_DEFAULTS objectForKey:@"devicesArray"];
    if (deviceArray.count == 1) {
        
    }else{
        [self performSegueWithIdentifier:@"ChooseDeviceController" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"ChooseDeviceController"]) {
        EPChooseDeviceController *chooseDeviceController = segue.destinationViewController;
        [chooseDeviceController setDeviceArray:deviceArray];
    }
}


@end
