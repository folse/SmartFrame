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
#import "EPRecordVoiceController.h"

@interface EPHomeController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate,AFPhotoEditorControllerDelegate>
{
    int editedId;
    int uploadId;
    BOOL needBindDevice;
    BOOL notUpdateDevive;
    BOOL isFinishUploadImage;
    UIImage *imageBefore;
    NSMutableArray *deviceArray;
    NSMutableArray *selectedPhotoArray;
    NSMutableArray *selectedAssetArray;
    MBProgressHUD *HUD;
    NSString *photoType;
    UIImagePickerController *imagePickerController;
}
@property (strong, nonatomic) IBOutlet UIImageView *lastPhotoImageView;

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
    
    if (USER_LOGIN) {
        
        if (!notUpdateDevive) {
            [[[NSThread alloc] initWithTarget:self selector:@selector(getDevice) object:nil] start];
        }
        
    }else{
        
        UINavigationController *regNavController = [STORY_BOARD instantiateViewControllerWithIdentifier:@"regNav"];
        [self presentViewController:regNavController animated:NO completion:nil];
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
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)];
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:imageTap];
    
    [self getUUID];
}

-(void)hideMenu
{
    JDSideMenu *sideMenu = (JDSideMenu *)self.navigationController.parentViewController;
    
    if (sideMenu.isMenuVisible) {
        [sideMenu hideMenuAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getDevice
{
    deviceArray = [USER_DEFAULTS objectForKey:@"deviceArray"];
    
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
    
    NSString *tokenId = [USER_DEFAULTS valueForKey:@"tokenId"];
    
    [parameterDict setObject:tokenId forKey:@"token"];
    
    s(parameterDict)
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:API_RELATION parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
        
        if ([[JSON valueForKey:@"code"] isEqualToString:@"1"]) {
            
            deviceArray = (NSMutableArray *)[JSON valueForKey:@"relations"];
            
            [USER_DEFAULTS setObject:deviceArray forKey:@"deviceArray"];
            
            if (deviceArray.count == 0) {
                
                needBindDevice = YES;
                
                [_lastPhotoImageView setImage:[UIImage imageNamed:@"need_bind_device"]];
                
            }else{
                
                needBindDevice = NO;
                
                [self getUserPhotos];
            }
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"获取相框信息失败" message:@"请稍后再试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)getUserPhotos
{
    deviceArray = [USER_DEFAULTS objectForKey:@"deviceArray"];
    
    NSMutableDictionary *parameterDict = [NSMutableDictionary new];
    NSString *tokenId = [USER_DEFAULTS valueForKey:@"tokenId"];
    [parameterDict setObject:[deviceArray firstObject][@"frameid"] forKey:@"frameid"];
    [parameterDict setObject:@"frame" forKey:@"type"];
    [parameterDict setObject:tokenId forKey:@"token"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:API_MANAGE_PHOTO parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
        
        if ([[JSON valueForKey:@"code"] isEqualToString:@"1"]) {
            
            NSArray *photoData = (NSArray *)[JSON valueForKey:@"date_photos"];
            
            if (photoData.count > 0) {
                
                NSArray *photos = (NSArray *)[photoData[0] valueForKey:@"photos"];
                
                [_lastPhotoImageView sd_setImageWithURL:[NSURL URLWithString:photos[0]] placeholderImage:[UIImage imageNamed:@"default_photo"]];
            }
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
    if (needBindDevice) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请绑定相框后发照片哦" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alertView show];
        
    }else{
        
        [selectedAssetArray removeAllObjects];
        [selectedPhotoArray removeAllObjects];
        
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerController animated:YES completion:^{
                photoType = @"CAMERA";
            }];
        }
    }
}

- (IBAction)albumButtonAction:(id)sender
{
    if (needBindDevice) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请绑定相框后发照片哦" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alertView show];
        
    }else{
        
        [self openAlbum:YES];
    }
}

-(void)openAlbum:(BOOL)animated
{
    editedId = 0;
    [selectedAssetArray removeAllObjects];
    [selectedPhotoArray removeAllObjects];
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection = 5;
    picker.navigationController.navigationItem.title = @"选取照片";
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.delegate = self;
    [self presentViewController:picker animated:animated completion:^{
        photoType = @"ALBUM";
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
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
    [AFPhotoEditorCustomization setToolOrder:@[kAFEffects,kAFCrop,kAFStickers, kAFDraw, kAFText,kAFOrientation,kAFEnhance,kAFAdjustments, kAFSharpness, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme, kAFFrames, kAFFocus]];
    [AFPhotoEditorCustomization setStatusBarStyle:UIStatusBarStyleLightContent];
    [AFPhotoEditorCustomization setNavBarImage:[self imageWithColor:APP_COLOR andSize:CGSizeMake(320, 44)]];
    [AFPhotoEditorCustomization setLeftNavigationBarButtonTitle:@"取消"];
    [AFPhotoEditorCustomization setRightNavigationBarButtonTitle:@"完成"];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:YES];
    [editorController setDelegate:self];
    [self presentViewController:editorController animated:YES completion:^{
        notUpdateDevive = YES;
        imageBefore = imageToEdit;
    }];
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
        
        [self saveToAlbum:image];
        
        if (selectedAssetArray.count > editedId) {
            
            ALAsset *asset = selectedAssetArray[editedId];
            
            imageBefore =[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            
            STRONGSELF
            [strongSelf displayEditorForImage:imageBefore];
            
        }else{
            
            [self finishEditingImage];
        }
    }];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [editor dismissViewControllerAnimated:NO completion:^{
        
        if ([photoType isEqualToString:@"ALBUM"]) {
            [self openAlbum:NO];
        }
    }];
}

-(void)finishEditingImage
{
    notUpdateDevive = NO;
    [self performSegueWithIdentifier:@"RecordVoiceController" sender:self];
}

-(void)saveToAlbum:(UIImage *)image
{
    NSData *imageBeforeData = UIImageJPEGRepresentation(imageBefore, 1.0);
    
    NSData *imageAfterData = UIImageJPEGRepresentation(image, 1.0);
    
    if (imageBeforeData.length != imageAfterData.length) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil,nil);
    }
}

-(void)getUUID
{
    NSString *uuid = [USER_DEFAULTS valueForKey:@"uuid"];
    
    if (uuid == nil || uuid.length == 0) {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
        
        [USER_DEFAULTS setValue:result forKey:@"uuid"];
        
        CFRelease(puuid);
        CFRelease(uuidString);
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"RecordVoiceController"]) {
        EPRecordVoiceController *recorderVoiceController = segue.destinationViewController;
        recorderVoiceController.deviceArray = deviceArray;
        recorderVoiceController.photoArray = selectedPhotoArray;
    }
}

@end
