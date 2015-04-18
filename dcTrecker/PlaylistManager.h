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
    Module *ourModule;
}

+(id)sharedPlaylist;
-(void)clearPlaylist;
-(void)addModule:(Module *)moduleToAdd;
-(void)removeModuleAtIndex:(NSInteger)ourRow;
-(Module *)getModuleAtIndex:(NSInteger)ourRow;
-(NSString *)getModuleLength:(NSInteger)ourRow;
-(NSInteger)playlistCount;
-(void)dumpPlaylist;

@end
