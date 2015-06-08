//
//  LibraryViewController.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Module.h"
#import "LibraryManager.h"

@interface LibraryViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

{
    LibraryManager *ourPlaylist;
    IBOutlet NSTableView *playlistTable;
    NSInteger currentRow;
}

-(void)reloadTable;
-(void)doubleClick:(id)object;
-(IBAction)addToPlaylist:(id)sender;
-(IBAction)removeFromPlaylist:(id)sender;
-(IBAction)newPlaylist:(id)sender;
-(IBAction)savePlaylistButton:(id)sender;
-(IBAction)loadPlaylistButton:(id)sender;
-(IBAction)writeModuleButton:(id)sender;

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
-(NSString *)newPlaylistToolTip;
-(NSString *)openPlaylistToolTip;
-(NSString *)savePlaylistToolTip;
-(NSString *)addModuleToolTip;
-(NSString *)removeModuleToolTip;
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

@end
