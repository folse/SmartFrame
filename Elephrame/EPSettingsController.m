//
//  EPSettingsController.m
//  Elephrame
//
//  Created by folse on 7/15/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "EPSettingsController.h"
#import <AviarySDK/AviarySDK.h>
#import "EAIntroView.h"

@interface EPSettingsController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,AFPhotoEditorControllerDelegate,EAIntroDelegate>
{
    UIImagePickerController *imagePickerController;
}
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;

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
    [self.userAvatarImageView.layer setMasksToBounds:YES];
    [self.userAvatarImageView.layer setBorderWidth:1.8];
    [self.userAvatarImageView.layer setBorderColor:[APP_COLOR CGColor]];
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
    
    
    NSString *avatarUrl = [USER_DEFAULTS valueForKey:@"avatarUrl"];
    if(avatarUrl != nil && avatarUrl.length > 0){
        [_userAvatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl]];
    }
    
    [_versionLabel setText:[NSString stringWithFormat:@"v%@",AppVersionShort]];
}

-(void)sendPhoto:(UIImage *)image
{
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", timeSp];
    
    NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
    
    NSString *UPLOAD_URL = [NSString stringWithFormat:@"%@?token=%@&type=%@&filename=%@",API_PORTRAIT,[USER_DEFAULTS valueForKeyPath:@"tokenId"],@"personal",fileName];
    s(UPLOAD_URL)
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:UPLOAD_URL parameters:parameterDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:fileData name:@"filename" fileName:fileName mimeType:@"image/jpeg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@:%@",operation.response.URL.relativePath,responseObject);
        [HUD hide:YES];
        
        if ([[responseObject valueForKey:@"code"] isEqualToString:@"1"]) {
            NSString *avatarUrl = [responseObject objectForKey:@"portrait"];
            saveValue(avatarUrl, @"avatarUrl")
            
        }else{
            NetWork_Error
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NetWork_Error
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
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePickerController setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:imagePickerController.sourceType]];
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
    [MobClick event:@"CLICK_SELECT_PIC_FROM_MOBILE"];
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:NO completion:^{
        
        [self displayEditorForImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma AFPhotoEditorControllerDelegate

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    [editor dismissViewControllerAnimated:YES completion:^{
        [_userAvatarImageView setImage:image];
        [self sendPhoto:image];
    }];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [editor dismissViewControllerAnimated:YES completion:nil];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
         [self showIntroView];
    }
}

-(void)showIntroView
{
    EAIntroPage *page1 = [EAIntroPage page];
    page1.bgImage = [UIImage imageNamed:@"a"];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:@"b"];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.bgImage = [UIImage imageNamed:@"c"];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
    intro.pageControlY = 110;
    [intro setFrame:CGRectMake(0,64, SCREEN_WIDTH, SCREEN_HEIGHT)];
    intro.tapToNext = YES;
    intro.swipeToExit = YES;
    intro.skipButton = nil;
    
    [intro setDelegate:self];
    
    [intro showInView:[[[UIApplication sharedApplication] delegate] window] animateDuration:0.0];
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
