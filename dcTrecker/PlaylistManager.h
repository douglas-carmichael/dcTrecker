//
//  PlaylistManager.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Module.h"
#import "xmp.h"

@interface PlaylistManager : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
    NSMutableArray *playlistArray;
    IBOutlet NSTableView *playlistTable;
    Module *ourModule;
}


-(void)clearPlaylist;
-(void)addModule:(Module *)moduleToAdd;
-(void)removeModule:(NSURL *)moduleURL;
-(void)dumpPlaylist;
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

@end
