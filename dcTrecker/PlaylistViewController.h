//
//  PlaylistViewController.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Module.h"
#import "PlaylistManager.h"

@interface PlaylistViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

{
    PlaylistManager *ourPlaylist;
    IBOutlet NSTableView *playlistTable;
    NSInteger currentRow;
}
-(IBAction)addToPlaylist:(id)sender;
-(IBAction)removeFromPlaylist:(id)sender;
-(IBAction)dumpPlaylist:(id)sender;
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
-(void)tableViewSelectionDidChange:(NSNotification *)notification;
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

@end
