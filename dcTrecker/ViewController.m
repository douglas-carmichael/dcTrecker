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
    [ourQueue setMaxConcurrentOperationCount:1];
    currentModule = 0;
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFromPlaylist:)
                                                 name:@"dcT_playFromPlaylist" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setModuleField:)
                                                 name:@"dcT_setModuleName" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cannotLoadModule:)
                                                 name:@"dcT_cannotLoadMod" object:nil];
    
    // Set up some notifications for the File menu options we need
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPlaylistMenu:)
                                                 name:@"dcT_openPlaylistMenu" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savePlaylistMenu:)
                                                 name:@"dcT_savePlaylistMenu" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAsPlaylistMenu:)
                                                 name:@"dcT_saveAsPlaylistMenu" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revertToSavedMenu:)
                                                 name:@"dcT_revertToSavedMenu" object:nil];

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

-(IBAction)playbackControl:(id)sender
{
    
    switch ([sender tag]) {
        case 0:
            if ([ourPlayer isPlaying])
            {
                if (currentModule == 0)
                {
                    break;
                }
                
                if ((currentModule - 1) <= ([ourPlaylist playlistCount] - 1))
                {
                    currentModule--;
                    [ourQueue cancelAllOperations];
                    ourModule = [ourPlaylist getModuleAtIndex:currentModule];
                    [self playModule:ourModule];
                    break;
                }
            }
        case 1:
            if ([ourPlayer isPlaying])
            {
                [ourPlayer prevPlayPosition];
            }
            break;
        case 2:
            if ([ourPlayer isPlaying])
            {
                [ourPlayer stopPlayer];
                [self resetView];
                break;
            }
            
            if ([ourPlaylist isEmpty])
            {
                [playButton setState:NSOffState];
                break;
            }
            
            ourModule = [ourPlaylist getModuleAtIndex:currentModule];
            [self playModule:ourModule];
            break;
        case 3:
            if ([ourPlayer isPlaying])
            {
                [ourPlayer nextPlayPosition];
            }
            break;
        case 4:
            if ([ourPlayer isPlaying])
            {
                if ((currentModule + 1) <= ([ourPlaylist playlistCount] - 1))
                {
                    currentModule++;
                    [ourQueue cancelAllOperations];
                    ourModule = [ourPlaylist getModuleAtIndex:currentModule];
                    [self playModule:ourModule];
                    break;
                }
            }
        default:
            break;
    }
}

-(void)openPlaylistMenu:(NSNotification *)ourNotification
{
    [ourPlaylist loadPlaylistDialog:[[self view] window]];
    return;
}

-(void)savePlaylistMenu:(NSNotification *)ourNotification
{
    if ([ourPlaylist currentPlaylist] != nil)
    {
        BOOL saveSuccess = [ourPlaylist savePlaylist:[ourPlaylist currentPlaylist]];
        if (saveSuccess == NO)
        {
            NSAlert *cannotSaveAlert = [[NSAlert alloc] init];
            NSString *playlistPath = [[[ourPlaylist currentPlaylist] path] lastPathComponent];
            [cannotSaveAlert addButtonWithTitle:@"OK"];
            [cannotSaveAlert setMessageText:@"Error"];
            [cannotSaveAlert setInformativeText:[NSString
                                                 stringWithFormat:@"Cannot save playlist: %@", playlistPath]];
            [cannotSaveAlert setAlertStyle:NSWarningAlertStyle];
        }
    }
    return;
}

-(void)saveAsPlaylistMenu:(NSNotification *)ourNotification
{
    [ourPlaylist savePlaylistDialog:[[self view] window]];
    return;
}

-(void)revertToSavedMenu:(NSNotification *)ourNotification
{
    if ([ourPlaylist currentPlaylist] == nil)
    {
        return;
    }


    BOOL playlistExists = [[NSFileManager defaultManager] fileExistsAtPath:[[ourPlaylist currentPlaylist] path]];
    if (playlistExists)
    {
        [ourPlaylist clearPlaylist:NO];
        BOOL loadSuccess = [ourPlaylist loadPlaylist:[ourPlaylist currentPlaylist]];
        if (loadSuccess == YES)
        {
            NSString *notificationName = @"dcT_ReloadPlaylist";
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
            return;
        }
    }
    return;
}

-(void)playFromPlaylist:(NSNotification *)ourNotification
{
    int passedRow = [[[ourNotification userInfo] valueForKey:@"currRow"] intValue];
    
    [ourQueue cancelAllOperations];
    [self resetView];
    
    currentModule = passedRow;
    ourModule = [ourPlaylist getModuleAtIndex:passedRow];
    [self playModule:ourModule];
    
}

-(void)setModuleField:(NSNotification *)ourNotification
{
    NSString *ourSetName = [[ourNotification userInfo] valueForKey:@"currModName"];
    [NSThread sleepForTimeInterval:0.10];
    [moduleName setStringValue:ourSetName];
}

-(void)cannotLoadModule:(NSNotification *)ourNotification
{
    NSAlert *cannotLoadAlert = [[NSAlert alloc] init];
    NSString *ourFilePath = [[ourNotification userInfo] valueForKey:@"currFilePath"];
    [cannotLoadAlert addButtonWithTitle:@"OK"];
    [cannotLoadAlert setMessageText:@"Error"];
    [cannotLoadAlert setInformativeText:[NSString
                                         stringWithFormat:@"Cannot load module: %@", ourFilePath]];
    [cannotLoadAlert setAlertStyle:NSWarningAlertStyle];
    
    // Cancel all playback operations to be safe.
    [ourQueue cancelAllOperations];
    [cannotLoadAlert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
    return;
}

-(void)resetView
{
    [playButton setState:NSOffState];
    [musicSlider setIntegerValue:0];
    [moduleTime setStringValue:@""];
    [moduleName setStringValue:@""];
}

-(void)playModule:(Module *)myModule
{
    PlaybackOperation *ourPlaybackOp;
    
    if ([ourPlaylist playlistCount] == 0)
    {
        [playButton setState:NSOffState];
        return;
    }
    
    if (![ourPlayer isPlaying])
    {
        ourPlaybackOp = [[PlaybackOperation alloc] initWithModule:myModule modPlayer:ourPlayer];
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
                NSInteger totalTime = myModule.modTotalTime;
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

@end
