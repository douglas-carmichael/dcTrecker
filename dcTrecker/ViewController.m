//
//  ViewController.m
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/6/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ourPlayer = [[xmpPlayer alloc] init];
    ourModule = [[Module alloc] init];
    ourQueue = [[NSOperationQueue alloc] init];
    [ourQueue setMaxConcurrentOperationCount:1];
    ourPlaylist = [PlaylistManager sharedPlaylist];
    currentModule = 0;
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFromPlaylist:)
                                                 name:@"dcT_playFromPlaylist" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setModuleField:)
                                                 name:@"dcT_setModuleName" object:nil];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

-(IBAction)playbackControl:(id)sender
{
    
    switch ([sender tag]) {
        case 0:
            NSLog(@"Previous Track.");
            break;
        case 1:
            [ourPlayer prevPlayPosition];
            break;
        case 2:
            NSLog(@"Play.");
            if ([ourPlayer isPlaying])
            {
                [ourPlayer stopPlayer];
                [self resetView];
                break;
            }
            [self playModule:(int)currentModule];
            break;
        case 3:
            [ourPlayer nextPlayPosition];
            break;
        case 4:
            NSLog(@"Next Track.");
            [ourQueue cancelAllOperations];
            break;
        default:
            break;
    }
}

-(void)playFromPlaylist:(NSNotification *)ourNotification
{
    int passedRow = [[[ourNotification userInfo] valueForKey:@"currRow"] intValue];
    
    [ourQueue cancelAllOperations];
    [self resetView];
    
    currentModule = passedRow;
    [self playModule:passedRow];
    
}

-(void)setModuleField:(NSNotification *)ourNotification
{
    NSString *ourSetName = [[ourNotification userInfo] valueForKey:@"currModName"];
    [NSThread sleepForTimeInterval:0.10];
    [moduleName setStringValue:ourSetName];
}

-(void)resetView
{
    [playButton setState:NSOffState];
    [musicSlider setIntegerValue:0];
    [moduleTime setStringValue:@""];
    [moduleName setStringValue:@""];
}

-(void)playModule:(int)moduleIndex
{
    PlaybackOperation *ourPlaybackOp;
    
    if ([ourPlaylist playlistCount] == 0)
    {
        [playButton setState:NSOffState];
        return;
    }
    
    if (![ourPlayer isPlaying])
    {
        Module *playModule = [ourPlaylist getModuleAtIndex:moduleIndex];
        ourPlaybackOp = [[PlaybackOperation alloc] initWithModule:playModule modPlayer:ourPlayer];
        [ourQueue setQualityOfService:NSOperationQualityOfServiceBackground];
        [ourQueue addOperation:ourPlaybackOp];
        while (![ourPlayer isPlaying])
        {
            // Wait here and do nothing until the AUGraph starts
        }
        [self setTimelineAvailable:YES];
        if ([ourPlayer isPlaying])
        {
            [playButton setState:NSOnState];
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE,0), ^{
                NSInteger totalTime = playModule.modTotalTime;
                [musicSlider setMaxValue:totalTime];
                while([ourPlayer isPlaying])
                {
                    usleep(100000);
                    if ([self timelineAvailable] == YES)
                    {
                        NSInteger sliderValue = [ourPlayer playerTime];
                        [musicSlider setIntegerValue:sliderValue];
                        [moduleTime setStringValue:[ourPlayer getTimeString:[ourPlayer playerTime]]];
                    }
                }
                [self resetView];
            });
        }
        return;
    }

    if ([ourPlayer isPlaying])
    {
        [ourPlayer stopPlayer];
        [self resetView];
        return;
    }
    
    return;
}

-(IBAction)volumeSet:(id)sender;
{
    float sliderVolume = [sender floatValue];
    float mixerVolume = [self scaleRange:sliderVolume];
    [ourPlayer setMasterVolume:mixerVolume];
}

-(float)scaleRange:(float)ourNumber
{
    
    // From:
    // http://stackoverflow.com/questions/10696794/objective-c-map-one-number-range-to-another
    
    CGFloat const inMin = 0.0;
    CGFloat const inMax = 10.0;
    
    CGFloat const outMin = 0.0;
    CGFloat const outMax = 1.0;
    
    CGFloat in = ourNumber;
    CGFloat out = outMin + (outMax - outMin) * (in - inMin) / (inMax - inMin);
    
    return out;
}

-(void)setModPosition:(int)ourValue
{
    [ourPlayer seekPlayerToTime:ourValue];
}

-(void)loadModule:(NSInteger)module
{
    NSError *ourError = nil;
    ourModule = [ourPlaylist getModuleAtIndex:module];
    [ourPlayer loadModule:ourModule error:&ourError];
    [moduleName setStringValue:ourModule.moduleName];
    [moduleTime setStringValue:[ourPlayer getTimeString:ourModule.modTotalTime]];
    
}
@end
