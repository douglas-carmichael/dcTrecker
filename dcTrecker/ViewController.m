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
            [self loadModule:0];
            if ([ourPlayer isLoaded])
            {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND,0), ^{
                    [ourPlayer playModule:nil];
                });
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

-(IBAction)volumeSet:(id)sender;
{
    [ourPlayer setMasterVolume:[sender floatValue]];
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
