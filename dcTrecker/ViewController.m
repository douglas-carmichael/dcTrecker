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
    ourPlaylist = [PlaylistManager sharedPlaylist];
    currentModule = 0;
    // Do any additional setup after loading the view.
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
            if ([ourPlaylist playlistCount] == 0)
            {
                [sender setState:NSOffState];
                break;
            }
            if (![ourPlayer isPlaying])
            {
                [self playModule:0];
                break;
            }
            if ([ourPlayer isPlaying])
            {
                [sender setState:NSOffState];
                [ourPlayer stopPlayer];
                break;
            }
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

-(void)playModule:(int)moduleIndex
{
    PlaybackOperation *ourPlayOp;
    
    Module *playModule = [ourPlaylist getModuleAtIndex:currentModule];
    [moduleName setStringValue:[playModule moduleName]];
    ourPlayOp = [[PlaybackOperation alloc] initWithModule:playModule modPlayer:ourPlayer];
    [ourQueue setQualityOfService:NSOperationQualityOfServiceUserInitiated];
    [ourQueue addOperation:ourPlayOp];
    usleep(10000);
    [self setDragTimeline:YES];
    if ([ourPlayer isPlaying])
    {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE,0), ^{
            NSInteger totalTime = playModule.modTotalTime;
            [musicSlider setMaxValue:totalTime];
            while([ourPlayer isPlaying])
            {
                usleep(10000);
                if ([self dragTimeline] == YES)
                {
                    NSInteger sliderValue = [ourPlayer playerTime];
                    [musicSlider setIntegerValue:sliderValue];
                    [moduleTime setStringValue:[ourPlayer getTimeString:[ourPlayer playerTime]]];
                }
            }
            [playButton setState:NSOffState];
            [musicSlider setIntegerValue:0];
            [moduleTime setStringValue:@""];
            [moduleName setStringValue:@""];
        });
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
