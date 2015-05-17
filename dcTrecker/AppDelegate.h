//
//  AppDelegate.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/6/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlaylistManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

{
    PlaylistManager *ourPlaylist;
}

-(IBAction)newPlaylist:(id)sender;
-(IBAction)openPlaylist:(id)sender;
-(IBAction)savePlaylist:(id)sender;
-(IBAction)saveAsPlaylist:(id)sender;
-(IBAction)revertToSaved:(id)sender;

@end

