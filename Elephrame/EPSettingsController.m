//
//  EPSettingsController.m
//  Elephrame
//
//  Created by folse on 7/15/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "EPSettingsController.h"
#import "CTAssetsPickerController.h"
#import <AviarySDK/AviarySDK.h>

@interface EPSettingsController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate,AFPhotoEditorControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *addAssets;

@end

@implementation EPSettingsController

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
    
    [self.userAvatarImageView setUserInteractionEnabled:YES];
    [self.userAvatarImageView bk_whenTapped:^{
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
        [actionSheet bk_addButtonWithTitle:@"从相册选取" handler:^{
            [MobClick event:@"Select_Album"];
            [self openAlbum];
        }];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [actionSheet bk_addButtonWithTitle:@"现在拍一张" handler:^{
                [MobClick event:@"Select_Camera"];
                [self openCamera];
            }];
        }
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [actionSheet showInView:self.view];
    }];
}

- (void)openCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }
}

-(void)openAlbum
{
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection = 5;
    picker.navigationController.navigationItem.title = @"选取照片";
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        
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
        
       
        
        
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil,nil);
        
            ALAsset *asset = image;
            UIImage *assetOriImage =[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            
            STRONGSELF
            [strongSelf displayEditorForImage:assetOriImage];

    }];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [editor dismissViewControllerAnimated:NO completion:^{

    }];
}

-(void)finishEditingImage
{
    [self performSegueWithIdentifier:@"RecordVoiceController" sender:self];
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

- (IBAction)logoutButtonAction:(id)sender
{
    [self resetDefaults];
    
    JDSideMenu *sideMenu = (JDSideMenu *)self.navigationController.parentViewController;
    UINavigationController *navController = [STORY_BOARD instantiateViewControllerWithIdentifier:@"mainNav"];
    [sideMenu setContentController:navController animated:NO];
    
    UINavigationController *regNavController = [STORY_BOARD instantiateViewControllerWithIdentifier:@"regNav"];
    
    [self presentViewController:regNavController animated:YES completion:nil];
    
}

- (void)resetDefaults
{
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        if (![key isEqualToString:@"moreThanFirstLoad"]) {
            [defs removeObjectForKey:key];
        }
    }
    [defs synchronize];
}

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
