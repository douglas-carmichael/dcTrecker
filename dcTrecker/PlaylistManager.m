//
//  PlaylistManager.m
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "PlaylistManager.h"

@implementation PlaylistManager

+(id)sharedPlaylist
{
    static PlaylistManager *sharedPlaylist = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlaylist = [[self alloc] init];
    });
    return sharedPlaylist;
}

- (id)init
{
    self = [super init];
    if (self) {
        playlistArray = [[NSMutableArray alloc] init];
        ourModule = [[Module alloc] init];
    }
    return self;
}

-(void)clearPlaylist
{
    [playlistArray removeAllObjects];
}

-(void)addModule:(Module *)moduleToAdd
{
    [playlistArray addObject:moduleToAdd];
}

-(Module *)getModuleAtIndex:(NSInteger)ourRow
{
    return [playlistArray objectAtIndex:ourRow];
}

-(BOOL)isEmpty
{
    if ([playlistArray count] == 0)
    {
        return YES;
    }
    return NO;
}

-(NSString *)getModuleLength:(NSInteger)ourRow
{
    xmp_context our_context;
    struct xmp_module_info pModuleInfo;
    int modTotalTime;
    our_context = xmp_create_context();
    
    // HACK: This could be done a bit more elegantly.
    
    // Get an instance of xmpPlayer to get ourselves getTimeString
    xmpPlayer *testPlayer = [[xmpPlayer alloc] init];
    
    // Grab the module path from the row
    Module *myModule = [[Module alloc] init];
    myModule = [playlistArray objectAtIndex:ourRow];
    
    NSURL *modulePath = [myModule filePath];
    
    // Load our module and grab the info we need
    xmp_load_module(our_context, (char *)[modulePath.path UTF8String]);
    xmp_get_module_info(our_context, &pModuleInfo);
    modTotalTime = pModuleInfo.seq_data[0].duration;
    
    // Unload the module and destroy our context
    xmp_release_module(our_context);
    xmp_free_context(our_context);
    
    // Convert modTotalTime to a string
    NSString *totalTimeString = [testPlayer getTimeString:modTotalTime];
    
    // Return it
    return totalTimeString;
}

-(void)removeModuleAtIndex:(NSInteger)ourRow
{
    [playlistArray removeObjectAtIndex:ourRow];
}

-(void)dumpPlaylist
{
    NSLog(@"%@", playlistArray);
    for (Module *PLModule in playlistArray)
    {
        NSLog(@"dumped path: %@", [PLModule filePath].path);
        
    }
}

-(NSInteger)playlistCount
{
    return playlistArray.count;
}

@end
