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

@end

