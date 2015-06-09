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
    ourLibrary = [LibraryManager sharedLibrary];
    [ourQueue setMaxConcurrentOperationCount:1];
    currentModule = 0;
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFromLibrary:)
                                                 name:@"dcT_playFromLibrary" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cannotLoadModule:)
                                                 name:@"dcT_cannotLoadMod" object:nil];
    
    // Set up some notifications for the File menu options we need
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openLibraryMenu:)
                                                 name:@"dcT_openLibraryMenu" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveLibraryMenu:)
                                                 name:@"dcT_saveLibraryMenu" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAsLibraryMenu:)
                                                 name:@"dcT_saveAsLibraryMenu" object:nil];
    
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
                if ((currentModule - 1) <= ([ourLibrary libraryCount] - 1))
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
            
            if ([ourLibrary isEmpty])
            {
                [playButton setState:NSOffState];
                break;
            }
            
            ourModule = [ourLibrary getModuleAtIndex:currentModule];
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
            if ((currentModule + 1) <= ([ourLibrary libraryCount] - 1))
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
            // Checking again here when we go through the library automatically
            NSLog(@"Playing next song.");
            if ((currentModule + 1) <= ([ourLibrary libraryCount] - 1))
            {
                currentModule++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    ourModule = [ourLibrary getModuleAtIndex:currentModule];
                    [self playModule:ourModule];
                });
            }
            break;
        }
        case kPlayPreviousSong:
        {
            NSLog(@"Playing previous song.");
            if ((currentModule - 1) <= ([ourLibrary libraryCount] - 1))
            {
                currentModule--;
                dispatch_async(dispatch_get_main_queue(), ^{
                    ourModule = [ourLibrary getModuleAtIndex:currentModule];
                    [self setSongPlaybackFlag:kPlayNextSong];
                    [self playModule:ourModule];
                });
            }
            break;
        }
        case kStopPlayback:
        {
            NSLog(@"Stopping playback.");
            [ourPlayer stopPlayer];
            [self setTimelineAvailable:NO];
            [self resetView];
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

-(void)resetView
{
    [playButton setState:NSOffState];
    [musicSlider setIntegerValue:0];
    [moduleName setStringValue:@""];
    [moduleTime setStringValue:@""];
}

-(void)openLibraryMenu:(NSNotification *)ourNotification
{
    [self performSegueWithIdentifier:@"librarySegue" sender:self];
    NSString *notificationName = @"dcT_loadLibrary";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    return;
}

-(void)saveLibraryMenu:(NSNotification *)ourNotification
{
    if ([ourLibrary currentLibrary] != nil)
    {
        BOOL saveSuccess = [ourLibrary saveLibrary:[ourLibrary currentLibrary]];
        if (saveSuccess == NO)
        {
            NSAlert *cannotSaveAlert = [[NSAlert alloc] init];
            NSString *libraryPath = [[[ourLibrary currentLibrary] path] lastPathComponent];
            [cannotSaveAlert addButtonWithTitle:@"OK"];
            [cannotSaveAlert setMessageText:@"Error"];
            [cannotSaveAlert setInformativeText:[NSString
                                                 stringWithFormat:@"Cannot save library: %@", libraryPath]];
            [cannotSaveAlert setAlertStyle:NSWarningAlertStyle];
        }
    }
    return;
}

-(void)addModuleMenu:(NSNotification *)ourNotification
{
    [self performSegueWithIdentifier:@"librarySegue" sender:self];
    NSString *notificationName = @"dcT_addLibrary";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    return;
}

-(void)saveAsLibraryMenu:(NSNotification *)ourNotification
{
    [self performSegueWithIdentifier:@"librarySegue" sender:self];
    NSString *notificationName = @"dcT_saveLibrary";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    return;
}

-(void)revertToSavedMenu:(NSNotification *)ourNotification
{
    if ([ourLibrary currentLibrary] == nil)
    {
        return;
    }
    
    
    BOOL libraryExists = [[NSFileManager defaultManager] fileExistsAtPath:[[ourLibrary currentLibrary] path]];
    if (libraryExists)
    {
        [ourLibrary clearLibrary:NO];
        BOOL loadSuccess = [ourLibrary loadLibrary:[ourLibrary currentLibrary]];
        if (loadSuccess == YES)
        {
            NSString *notificationName = @"dcT_reloadLibrary";
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
            return;
        }
    }
    return;
}

-(void)playFromLibrary:(NSNotification *)ourNotification
{
    int passedRow = [[[ourNotification userInfo] valueForKey:@"currRow"] intValue];
    
    [self setSongPlaybackFlag:kPlayNormal];
    [ourQueue cancelAllOperations];
    
    currentModule = passedRow;
    ourModule = [ourLibrary getModuleAtIndex:passedRow];
    if ((currentModule + 1) > ([ourLibrary libraryCount] - 1))
    {
        [self setSongPlaybackFlag:kStopPlayback];
    }
    else
    {
        [self setSongPlaybackFlag:kPlayNextSong];
    }
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
    
    if ([ourLibrary libraryCount] == 0)
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
