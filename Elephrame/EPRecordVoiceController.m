//
//  EPRecordVoiceController.m
//  Elephrame
//
//  Created by Jennifer on 7/20/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "EPRecordVoiceController.h"
#import "LCVoice.h"
#import <AVFoundation/AVFoundation.h>

@interface EPRecordVoiceController ()<AVAudioPlayerDelegate>
{
    UIImage *firstImage;
    NSData *fileData;
    NSString *filename;
    NSString *filetype;
    NSString *mimetype;
    NSString *voiceName;
    NSArray *selectedDeviceArray;
    NSMutableArray *photoNameArray;
}

@property(nonatomic,retain) LCVoice * voice;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@end

@implementation EPRecordVoiceController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.voice = [[LCVoice alloc] init];
    
    [_recordButton addTarget:self action:@selector(recordStart) forControlEvents:UIControlEventTouchDown];
    [_recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchDragOutside];
    [_recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpOutside];
    
    [_recordButton setTitle:@"按住说话" forState:UIControlStateNormal];
    [_recordButton setTitle:@"松手结束" forState:UIControlStateHighlighted];
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordEnd)];
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:imageTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishChooseDevice:) name:@"afterChooseDevice" object:nil];
}

- (IBAction)playButtonAction:(id)sender
{
    if (self.player != nil && self.player.playing) {
        
        [_playButton setImage:[UIImage imageNamed:@"mic_play_358x358"] forState:UIControlStateNormal];
        
        [self.player stop];
        
    }else if(self.voice.recordPath.length > 0){
        
        [_playButton setImage:[UIImage imageNamed:@"mic_stop_358x358"] forState:UIControlStateNormal];
        
        GCDBACK(^{
            
            NSURL *url = [NSURL fileURLWithPath:self.voice.recordPath];
            
            self.player = [[AVAudioPlayer alloc]
                           initWithContentsOfURL:url error:nil];
            [self.player setDelegate:self];
            [self.player setVolume:1.0];
            [self.player prepareToPlay];
            [self.player play];
        });
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_playButton setImage:[UIImage imageNamed:@"mic_play_358x358"] forState:UIControlStateNormal];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [_playButton setImage:[UIImage imageNamed:@"mic_play_358x358"] forState:UIControlStateNormal];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [_playButton setImage:[UIImage imageNamed:@"mic_play_358x358"] forState:UIControlStateNormal];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    if (flags == AVAudioSessionInterruptionOptionShouldResume && player != nil){
        
        [player play];
        
        [_playButton setImage:[UIImage imageNamed:@"mic_stop_358x358"] forState:UIControlStateNormal];
    }
}

-(void)recordStart
{
    [_playButton setImage:[UIImage imageNamed:@"mic_normal_358x358"] forState:UIControlStateNormal];
    
    [self.voice startRecordWithPath:[NSString stringWithFormat:@"%@/Documents/MySound.caf", NSHomeDirectory()]];
}

-(void)recordEnd
{
    [self.voice stopRecordWithCompletionBlock:^{
        
        if (self.voice.recordTime > 0.0f) {
            [_playButton setImage:[UIImage imageNamed:@"mic_play_358x358"] forState:UIControlStateNormal];
        }
    }];
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

-(void)finishChooseDevice:(NSNotification *)notification
{
    selectedDeviceArray = [notification.userInfo objectForKey:@"deviceArray"];
    [self sendPhotoAndVoice];
}

-(void)sendPhotoAndVoice
{
    [HUD show:YES];
    
    firstImage = _photoArray[0];
    
    photoNameArray = [NSMutableArray new];
    
    for (int i = 0; i < _photoArray.count; i++) {
        [photoNameArray addObject:[NSString stringWithFormat:@"%ld.jpg", (long)[[NSDate date] timeIntervalSince1970]]];
    }
        
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    voiceName = [NSString stringWithFormat:@"%@.caf", timeSp];
    
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
    
    [parameterDict setObject:[USER_DEFAULTS valueForKeyPath:@"tokenId"] forKey:@"token"];
    [parameterDict setObject:selectedDeviceArray forKey:@"frameid"];
    [parameterDict setObject:photoNameArray forKey:@"photo"];
    [parameterDict setObject:[NSArray arrayWithObject:voiceName] forKey:@"voice"];
    s(parameterDict)
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:API_SEND_PHOTO_VOICE parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@:%@",operation.response.URL.relativePath,responseObject);
        
        if ([[responseObject valueForKey:@"code"] isEqualToString:@"1"]) {
            
             [self uploadPhotoAndVoice];
            
        }else{
            NetWork_Error
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NetWork_Error
    }];
}

-(void)uploadPhotoAndVoice
{
    if(_photoArray.count > 0){
        
        filename = photoNameArray[0];
        filetype = @"photo";
        mimetype = @"image/jpeg";
        
        fileData = UIImageJPEGRepresentation(_photoArray[0], 1.0);
        
    }else if(self.voice != nil && self.voice.recordPath.length > 0){
        
        filename = voiceName;
        filetype = @"voice";
        mimetype = @"audio/x-caf";
        
        NSURL *url = [NSURL fileURLWithPath:self.voice.recordPath];
        
        fileData = [NSData dataWithContentsOfURL:url];
        
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [HUD setHidden:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"afterSendPhoto" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:firstImage, @"sentPhoto", nil]];
        
        return;
    }
    
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
    [parameterDict setObject:filetype forKey:@"filetype"];
    [parameterDict setObject:[USER_DEFAULTS valueForKeyPath:@"tokenId"] forKey:@"token"];
    
    NSString *UPLOAD_URL = [NSString stringWithFormat:@"%@?token=%@&filetype=photo&filename=%@",API_UPLOAD,[USER_DEFAULTS valueForKeyPath:@"tokenId"],@"1405834462.jpg"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:UPLOAD_URL parameters:parameterDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:fileData name:@"filename" fileName:filename mimeType:mimetype];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@:%@",operation.response.URL.relativePath,responseObject);
        [HUD hide:YES];
        
        if ([[responseObject valueForKey:@"code"] isEqualToString:@"1"]) {
            
            if(_photoArray.count > 0){
                
                [_photoArray removeObjectAtIndex:0];
                [photoNameArray removeObjectAtIndex:0];
            }
            
            if ([filetype isEqualToString:@"voice"]) {
                
                [self.navigationController popViewControllerAnimated:YES];
                
                [HUD setHidden:YES];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"afterSendPhoto" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:firstImage, @"sentPhoto", nil]];
                
            }else{
                
                [self uploadPhotoAndVoice];
            }
            
        }else{
            NetWork_Error
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NetWork_Error
    }];
}

- (IBAction)sendButtonAction:(id)sender
{
    if (_deviceArray.count == 1) {
        
        NSString *selectedDeviceId = _deviceArray[0][@"frameid"];
        
        selectedDeviceArray = [NSArray arrayWithObject:selectedDeviceId];
        
        [self sendPhotoAndVoice];
        
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
