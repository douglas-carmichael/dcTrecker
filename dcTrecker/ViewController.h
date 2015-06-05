//
//  ViewController.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/6/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlaylistManager.h"
#import "PlaybackOperation.h"

@interface ViewController : NSViewController
{
    xmpPlayer *ourPlayer;
    Module *ourModule;
    PlaylistManager *ourPlaylist;
    NSOperationQueue *ourQueue;
    NSInteger currentModule;
    IBOutlet NSTextField *moduleName;
    IBOutlet NSTextField *moduleTime;
    IBOutlet NSButton *playButton;
    IBOutlet NSSlider *musicSlider;
}

typedef enum {
    kPlayPreviousSong = 1,
    kPlayNextSong,
    kStopPlayback,
    kPlayNormal
} kSongPlayback;

-(IBAction)volumeSet:(id)sender;
-(void)playFromPlaylist:(NSNotification *)ourNotification;
-(void)openPlaylistMenu:(NSNotification *)ourNotification;
-(void)savePlaylistMenu:(NSNotification *)ourNotification;
-(void)saveAsPlaylistMenu:(NSNotification *)ourNotification;
-(void)revertToSavedMenu:(NSNotification *)ourNotification;
-(void)addModuleMenu:(NSNotification *)ourNotification;
-(void)setModPosition:(int)ourValue;
-(void)playModule:(Module *)playModule;
-(BOOL)isGraphRunning;

@property (assign) BOOL timelineAvailable;
@property (assign) kSongPlayback songPlaybackFlag;

@end

