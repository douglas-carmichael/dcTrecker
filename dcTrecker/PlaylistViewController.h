//
//  PlaylistViewController.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Module.h"

@interface PlaylistViewController : NSViewController

{
    IBOutlet NSTableView *playlistTable;
    
}
-(IBAction)addToPlaylist:(id)sender;
-(IBAction)removeFromPlaylist:(id)sender;

@end
