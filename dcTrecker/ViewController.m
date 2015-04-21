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
    NSLog(@"Playlist count: %li", (long)[ourPlaylist playlistCount]);
    switch ([sender tag]) {
        case 0:
            NSLog(@"Previous Track.");
            break;
        case 1:
            NSLog(@"Previous Position.");
            break;
        case 2:
            NSLog(@"Play.");
            if (![ourPlayer isPlaying])
            {
                [sender setState:NSOnState];
                usleep(1000);
                [self playThroughPlaylist];
                [sender setState:NSOffState];
            }
            if ([ourPlayer isPlaying])
            {
                [ourPlayer stopPlayer];
            }
            break;
        case 3:
            NSLog(@"Next Position.");
            break;
        case 4:
            NSLog(@"Next Track.");
            break;
        default:
            break;
    }
}

-(void)playThroughPlaylist
{
    if (![ourPlayer isPlaying])
    {
        while (currentModule <= ([ourPlaylist playlistCount]) - 1)
        {
            NSLog(@"playing module: %ld", (long)currentModule);
            Module *myModule = [[Module alloc] init];
            myModule = [ourPlaylist getModuleAtIndex:currentModule];
            currentModule++;
        }
    }
}

-(void)setModPosition:(NSInteger)currPosition
{
    [ourPlayer jumpPosition:currPosition];
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

-(void)loadModule:(NSInteger)module
{
    NSError *ourError = nil;
    ourModule = [ourPlaylist getModuleAtIndex:module];
    [ourPlayer loadModule:ourModule error:&ourError];
    [moduleName setStringValue:ourModule.moduleName];
    [moduleTime setStringValue:[ourPlayer getTimeString:ourModule.modTotalTime]];
    
}
@end
