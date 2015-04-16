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
    NSLog(@"module URL path: %@", [moduleToAdd filePath]);
    NSLog(@"array count before add: %lu", (unsigned long)playlistArray.count);
    [playlistArray addObject:moduleToAdd];
    NSLog(@"array count after add: %lu", (unsigned long)playlistArray.count);
    [self->playlistTable reloadData];
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
        NSLog(@"dumped path: %@", [PLModule filePath]);
        
    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSLog(@"numberOfRowsInTableView: %lu", (unsigned long)playlistArray.count);
    return playlistArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSLog(@"called idTableView");
    NSLog(@"tableColumn.identifier: %@", tableColumn.identifier);
    if([tableColumn.identifier isEqualToString:@"Title"])
    {
        Module *ourObject = [playlistArray objectAtIndex:row];
        NSLog(@"Returning data.");
        return [ourObject moduleName];
    }
    NSLog(@"Returning nil.");
    return nil;
}

@end
