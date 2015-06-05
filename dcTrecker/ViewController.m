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
    
    
    // Set up some notifications for our Playlist menu options
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addModuleMenu:)
                                                 name:@"dcT_addModuleMenu" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextSong:)
                                                 name:@"dcT_nextSong" object:nil];
    
    
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
                    [self setSongPlaybackFlag:kPlayPreviousSong];
                    [ourPlayer stopPlayer];
                }
                break;
            }
        case 1:
            if ([ourPlayer isPlaying])
            {
                if (![ourPlayer isPaused])
                {
                    [ourPlayer prevPlayPosition];
                }
            }
            break;
        case 2:
            if ([ourPlayer isPlaying])
            {
                [self setSongPlaybackFlag:kPlayNormal];
                [ourPlayer pauseResume];
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
                if (![ourPlayer isPaused])
                {
                    [ourPlayer nextPlayPosition];
                }
            }
            break;
        case 4:
            if ((currentModule + 1) <= ([ourPlaylist playlistCount] - 1))
            {
                [self setSongPlaybackFlag:kPlayNextSong];
                [ourPlayer stopPlayer];
            }
            break;
        default:
            break;
    }
}

-(void)nextSong:(NSNotification *)ourNotification
{
    switch ([self songPlaybackFlag])
    {
        case kPlayNextSong:
        {
            // Checking again here when we go through the playlist automatically
            
            if ((currentModule + 1) <= ([ourPlaylist playlistCount] - 1))
            {
                currentModule++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    ourModule = [ourPlaylist getModuleAtIndex:currentModule];
                    [self playModule:ourModule];
                });
            }
            break;
        }
        case kPlayPreviousSong:
        {
            if ((currentModule - 1) <= ([ourPlaylist playlistCount] - 1))
            {
                currentModule--;
                dispatch_async(dispatch_get_main_queue(), ^{
                    ourModule = [ourPlaylist getModuleAtIndex:currentModule];
                    [self setSongPlaybackFlag:kPlayNextSong];
                    [self playModule:ourModule];
                });
            }
            break;
        }
        default:
        {
            break;
        }
    }
    return;
}

-(BOOL)isGraphRunning
{
    return [ourPlayer isGraphRunning];
}

-(void)openPlaylistMenu:(NSNotification *)ourNotification
{
    [self performSegueWithIdentifier:@"playlistSegue" sender:self];
    NSString *notificationName = @"dcT_loadPlaylist";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
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

-(void)addModuleMenu:(NSNotification *)ourNotification
{
    [self performSegueWithIdentifier:@"playlistSegue" sender:self];
    NSString *notificationName = @"dcT_addPlaylist";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    return;
}

-(void)saveAsPlaylistMenu:(NSNotification *)ourNotification
{
    [self performSegueWithIdentifier:@"playlistSegue" sender:self];
    NSString *notificationName = @"dcT_savePlaylist";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
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
            NSString *notificationName = @"dcT_reloadPlaylist";
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
            return;
        }
    }
    return;
}

-(void)playFromPlaylist:(NSNotification *)ourNotification
{
    int passedRow = [[[ourNotification userInfo] valueForKey:@"currRow"] intValue];
    
    [self setSongPlaybackFlag:kPlayNormal];
    [ourQueue cancelAllOperations];
    
    currentModule = passedRow;
    ourModule = [ourPlaylist getModuleAtIndex:passedRow];
    [self setSongPlaybackFlag:kPlayNextSong];
    [self playModule:ourModule];
    
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
            NSInteger totalTime = myModule.modTotalTime;
            [playButton setState:NSOnState];
            [moduleName setStringValue:[myModule moduleName]];
            [musicSlider setMaxValue:totalTime];
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE,0), ^{
                while([ourPlayer isPlaying])
                {
                    usleep(100000);
                    if ([self timelineAvailable] == YES)
                    {
                        NSInteger sliderValue = [ourPlayer playerTime];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [musicSlider setIntegerValue:sliderValue];
                            [moduleTime setStringValue:[ourPlayer getTimeString:[ourPlayer playerTime]]];
                        });
                    }
                }
            });
        }
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
