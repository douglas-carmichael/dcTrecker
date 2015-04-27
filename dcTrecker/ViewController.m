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
    PlaybackOperation *ourPlayOp;
    
    NSLog(@"Playlist count: %li", (long)[ourPlaylist playlistCount]);
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
                NSLog(@"playlist 0.");
                break;
            }
            if (![ourPlayer isPlaying])
            {
                [sender setState:NSOnState];
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
                    while (currentModule <= ([ourPlaylist playlistCount]) - 1)
                    {
                        NSLog(@"playing module: %ld", (long)currentModule);
                        Module *myModule = [[Module alloc] init];
                        myModule = [ourPlaylist getModuleAtIndex:currentModule];
                        NSLog(@"module name: %@", [myModule moduleName]);
                        [ourPlayer loadModule:myModule error:nil];
                        [ourPlayer playModule:nil];
                        [ourPlayer unloadModule];
                        currentModule++;
                    }
                });
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
            ourPlayOp = [[PlaybackOperation alloc] initWithModule:[ourPlaylist getModuleAtIndex:0]];
            [ourQueue addOperation:ourPlayOp];
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
