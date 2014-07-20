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

@interface EPRecordVoiceController ()

@property(nonatomic,retain) LCVoice * voice;

@property (strong, nonatomic) AVAudioPlayer* player;

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
    
    [_recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    
    [_recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpOutside];
    
    [_recordButton setTitle:@"按住说话" forState:UIControlStateNormal];
    
    [_recordButton setTitle:@"松手结束" forState:UIControlStateHighlighted];
}

- (IBAction)playButtonAction:(id)sender
{
    if (self.player.playing) {
        
        [_playButton setImage:[UIImage imageNamed:@"mic_play_358x358"] forState:UIControlStateNormal];

        [self.player stop];
        
    }else{
        
        [_playButton setImage:[UIImage imageNamed:@"mic_stop_358x358"] forState:UIControlStateNormal];
        
        GCDBACK(^{
            
            NSURL *url = [NSURL fileURLWithPath:self.voice.recordPath];
            
            self.player = [[AVAudioPlayer alloc]
                           initWithContentsOfURL:url error:nil];
            [self.player setVolume:1.0];
            [self.player prepareToPlay];
            [self.player play];
            
        });
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
