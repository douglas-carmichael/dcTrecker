//
//  ViewController.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/6/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "xmpPlayer.h"
#import "PlaylistManager.h"

@interface ViewController : NSViewController
{
    xmpPlayer *ourPlayer;
    Module *ourModule;
    PlaylistManager *ourPlaylist;
    NSInteger *currentModule;
    IBOutlet NSTextField *moduleName;
    IBOutlet NSTextField *moduleTime;
    IBOutlet NSTextField *modulePosition;
}

-(IBAction)volumeSet:(id)sender;

@end

