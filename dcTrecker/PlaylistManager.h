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
#import "xmpPlayer.h"

@interface PlaylistManager : NSObject
{
    NSMutableArray *playlistArray;
}

+(id)sharedPlaylist;
-(void)clearPlaylist:(BOOL)clearCurrentProperty;
-(void)savePlaylistDialog:(NSWindow *)ourWindow;
-(void)loadPlaylistDialog:(NSWindow *)ourWindow;
-(void)addToPlaylistDialog:(NSWindow *)ourWindow;
-(BOOL)savePlaylist:(NSURL *)myPlaylist;
-(BOOL)loadPlaylist:(NSURL *)myPlaylist;
-(void)addModule:(Module *)moduleToAdd;
-(void)removeModuleAtIndex:(NSInteger)ourRow;
-(Module *)getModuleAtIndex:(NSInteger)ourRow;
-(NSString *)getModuleLength:(NSInteger)ourRow;
-(NSInteger)playlistCount;
-(BOOL)isEmpty;

@property (readonly) NSURL *currentPlaylist;

@end
