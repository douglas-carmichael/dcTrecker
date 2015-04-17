//
//  PlaylistManager.m
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "PlaylistManager.h"

@implementation PlaylistManager

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
    
    // Display our module's path
    NSLog(@"module URL path: %@", [moduleToAdd filePath]);

    NSLog(@"array count before add: %lu", (unsigned long)playlistArray.count);
    [playlistArray addObject:moduleToAdd];
    NSLog(@"array count after add: %lu", (unsigned long)playlistArray.count);
}

-(Module *)getModuleAtIndex:(NSInteger)ourRow
{
    return [playlistArray objectAtIndex:ourRow];
}

-(void)removeModule:(NSURL *)moduleURL
{
    Module *removeProto = [[Module alloc] init];
    [removeProto setFilePath:moduleURL];
    [playlistArray removeObject:removeProto];
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
