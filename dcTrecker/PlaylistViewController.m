//
//  PlaylistViewController.m
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "PlaylistViewController.h"

@interface PlaylistViewController ()

@end

@implementation PlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    ourPlaylist = [PlaylistManager sharedPlaylist];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"dcT_ReloadPlaylist" object:nil];
}

-(void)awakeFromNib
{
    [playlistTable setDoubleAction:@selector(doubleClick:)];
}

-(void)reloadTable
{
    [playlistTable reloadData];
}

-(IBAction)addToPlaylist:(id)sender
{
    [ourPlaylist addToPlaylistDialog:[[self view] window]];
    return;
}

-(IBAction)removeFromPlaylist:(id)sender
{
    [ourPlaylist removeModuleAtIndex:currentRow];
    return;
}

-(IBAction)newPlaylist:(id)sender
{
    [ourPlaylist clearPlaylist];
    NSString *notificationName = @"dcT_ReloadPlaylist";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    
}

-(IBAction)savePlaylistButton:(id)sender
{
    [ourPlaylist savePlaylistDialog:[[self view] window]];
    return;
}

-(IBAction)loadPlaylistButton:(id)sender
{
    [ourPlaylist loadPlaylistDialog:[[self view] window]];
    [playlistTable reloadData];
    return;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [ourPlaylist playlistCount];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    // Check for an empty array, and return nil if it is
    if ([ourPlaylist isEmpty] == YES)
    {
        return nil;
    }
    
    Module *ourObject = [ourPlaylist getModuleAtIndex:row];
    if([tableColumn.identifier isEqualToString:@"Title"])
    {
        return [ourObject moduleName];
    } else
    {
        if([tableColumn.identifier isEqualToString:@"Type"])
        {
            return [ourObject moduleType];
        }
        if ([tableColumn.identifier isEqualToString:@"Time"])
        {
            NSString *ourModuleLength = [ourPlaylist getModuleLength:row];
            return ourModuleLength;
        }
    }
    return nil;
}

-(void)doubleClick:(id)object
{
    NSTableView *tableView = object;
    currentRow = tableView.selectedRow;
    
    if (currentRow >= 0)
    {
        NSDictionary *currRowDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithLong:currentRow] forKey:@"currRow"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dcT_playFromPlaylist" object:nil userInfo:currRowDict];
    }
    
}
@end
