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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.voice = [[LCVoice alloc] init];
    
    [_recordButton addTarget:self action:@selector(recordStart) forControlEvents:UIControlEventTouchDown];
//    [_recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchDragExit];
//    [_recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchDragInside];
    [_recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchDragOutside];
    [_recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpOutside];
    
    [_recordButton setTitle:@"按住说话" forState:UIControlStateNormal];
    [_recordButton setTitle:@"松手结束" forState:UIControlStateHighlighted];
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordEnd)];
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:imageTap];
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
