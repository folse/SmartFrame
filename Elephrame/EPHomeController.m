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
#import <AviarySDK/AviarySDK.h>

@interface EPHomeController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate,AFPhotoEditorControllerDelegate>
{
    int editedId;
    int uploadId;
    BOOL isFinishUploadImage;
    NSMutableArray *deviceArray;
    NSMutableArray *selectedPhotoArray;
    NSMutableArray *selectedAssetArray;
    MBProgressHUD *HUD;
}

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *addAssets;

@end

@implementation EPHomeController


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
    selectedAssetArray = [NSMutableArray new];
    selectedPhotoArray = [NSMutableArray new];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AFPhotoEditorController setAPIKey:@"edc762d6aef61bea" secret:@"73429c0222c8298d"];
    });
    
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
        
        [selectedAssetArray removeAllObjects];
        [selectedPhotoArray removeAllObjects];
        
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
    editedId = 0;
    [selectedAssetArray removeAllObjects];
    [selectedPhotoArray removeAllObjects];
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection = 5;
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
        
        [self displayEditorForImage:info[UIImagePickerControllerOriginalImage]];
    }];
}

#pragma mark Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (![assets count]) return;
    [self.addAssets removeAllObjects];
    [self.assets addObjectsFromArray:assets];
    [self.addAssets addObjectsFromArray:assets];
    
    selectedAssetArray = [NSMutableArray arrayWithArray:assets];
    
    ALAsset *asset = assets[0];
    UIImage *assetOriImage =[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    
    WEAKSELF
    [picker dismissViewControllerAnimated:NO completion:^{
        STRONGSELF
        [strongSelf displayEditorForImage:assetOriImage];
    }];
}

#pragma AFPhotoEditorControllerDelegate

- (void)displayEditorForImage:(UIImage *)imageToEdit
{
    AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
    [AFPhotoEditorCustomization setToolOrder:@[kAFEffects,kAFStickers, kAFDraw, kAFText,kAFOrientation,kAFEnhance,kAFAdjustments, kAFSharpness, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme, kAFFrames, kAFFocus]];
    [AFPhotoEditorCustomization setStatusBarStyle:UIStatusBarStyleLightContent];
    [AFPhotoEditorCustomization setNavBarImage:[self imageWithColor:APP_COLOR andSize:CGSizeMake(320, 44)]];
    [editorController setDelegate:self];
    [self presentViewController:editorController animated:YES completion:nil];
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    WEAKSELF
    [editor dismissViewControllerAnimated:YES completion:^{
        
        [selectedPhotoArray addObject:image];
        
        editedId += 1;
        
        if (selectedAssetArray.count > editedId) {
            
            ALAsset *asset = selectedAssetArray[editedId];
            UIImage *assetOriImage =[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            
            STRONGSELF
            [strongSelf displayEditorForImage:assetOriImage];
            
        }else{
            
            [self finishEditingImage];
        }
    }];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [editor dismissViewControllerAnimated:YES completion:nil];
}

-(void)finishEditingImage
{
    if (deviceArray.count == 1) {
        
        [self uploadImageToDevice:deviceArray[0][@"frameid"]];
        
    }else{
        
        [self performSegueWithIdentifier:@"ChooseDeviceController" sender:self];
    }
}

-(void)uploadImageToDevice:(NSNotification *)notification
{
//    NSLog(@"%@", [notification.userInfo objectForKey:@"deviceId"]);
//    
//    [HUD show:YES];
//    
//    NSData *imageData = UIImageJPEGRepresentation(selectedPhotoArray[0], 1.0);
//    
//    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
//    NSString *photoName = [NSString stringWithFormat:@"%@.jpg", timeSp];
//    
//    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
//    
//    [parameterDict setObject:[USER_DEFAULTS valueForKeyPath:@"tokenId"] forKey:@"token"];
//    [parameterDict setObject:[NSArray arrayWithObjects:[notification.userInfo objectForKey:@"deviceId"], nil] forKey:@"frameid"];
//    [parameterDict setObject:[NSArray arrayWithObjects:photoName, nil] forKey:@"photo"];
//    [parameterDict setObject:[NSArray arrayWithObjects:photoName, nil] forKey:@"voice"];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager POST:API_SEND_PHOTO_VOICE parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSLog(@"%@:%@",operation.response.URL.relativePath,responseObject);
//        [HUD hide:YES];
//        
//        if ([[responseObject valueForKey:@"code"] isEqualToString:@"1"]) {
//            
//            
//            
//        }else{
//            NetWork_Error
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NetWork_Error
//    }];
    
    
     [self uploadImage];
}

-(void)uploadImage
{
    [HUD show:YES];
    
    NSData *imageData = UIImageJPEGRepresentation(selectedPhotoArray[0], 1.0);
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *photoName = [NSString stringWithFormat:@"%@.jpg", timeSp];
    
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
    [parameterDict setObject:@"photo" forKey:@"filetype"];
    [parameterDict setObject:[USER_DEFAULTS valueForKeyPath:@"tokenId"] forKey:@"token"];
    
    
    NSString *UPLOAD_URL = [NSString stringWithFormat:@"%@?token=%@&filetype=photo&filename=%@",API_UPLOAD,[USER_DEFAULTS valueForKeyPath:@"tokenId"],@"1405834462.jpg"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:UPLOAD_URL parameters:parameterDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageData name:@"filename" fileName:@"1405834462.jpg" mimeType:@"image/jpeg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@:%@",operation.response.URL.relativePath,responseObject);
        [HUD hide:YES];
        
        if ([[responseObject valueForKey:@"code"] isEqualToString:@"1"]) {
            
            
            
        }else{
            NetWork_Error
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NetWork_Error
    }];
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
