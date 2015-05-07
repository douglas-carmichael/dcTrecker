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

-(IBAction)volumeSet:(id)sender;
-(void)playFromPlaylist:(NSNotification *)ourNotification;
-(void)resetView;
-(void)setModPosition:(int)ourValue;
-(void)playModule:(int)moduleIndex;

@property (assign) BOOL timelineAvailable;

@end

