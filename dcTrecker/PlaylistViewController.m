//
//  PlaylistViewController.m
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "PlaylistViewController.h"

@interface PlaylistViewController ()

@end

@implementation PlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    ourPlaylist = [[PlaylistManager alloc] init];
}

-(IBAction)addToPlaylist:(id)sender
{
    NSError *ourError = nil;
    NSOpenPanel *ourPanel = [NSOpenPanel openPanel];
    Module *ourModule = [[Module alloc] init];
    
    [ourPanel setCanChooseDirectories:NO];
    [ourPanel setCanChooseFiles:YES];
    [ourPanel setCanCreateDirectories:NO];
    [ourPanel setAllowsMultipleSelection:NO];
    if ([ourPanel runModal] == NSModalResponseOK)
    {
        [ourModule setFilePath:[ourPanel URL]];
        if(ourError)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Cannot load module."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            return;
        }
        
    }

    [ourPlaylist addModule:ourModule];
}

-(IBAction)dumpPlaylist:(id)sender
{
    [ourPlaylist dumpPlaylist];
}

-(IBAction)removeFromPlaylist:(id)sender
{
    NSLog(@"Remove from playlist not implemented yet!");
}


@end
