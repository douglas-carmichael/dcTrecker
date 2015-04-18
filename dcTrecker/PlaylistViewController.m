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
}

-(void)viewDidAppear
{
    [super viewDidAppear];
    [playlistTable reloadData];
}

-(IBAction)addToPlaylist:(id)sender
{
    NSOpenPanel *ourPanel = [NSOpenPanel openPanel];
    Module *ourModule = [[Module alloc] init];
    
    [ourPanel setCanChooseDirectories:NO];
    [ourPanel setCanChooseFiles:YES];
    [ourPanel setCanCreateDirectories:NO];
    [ourPanel setAllowsMultipleSelection:NO];
    if ([ourPanel runModal] == NSModalResponseOK)
    {
        struct xmp_test_info moduleTestInfo;
        int status;
        NSURL *moduleURL = [ourPanel URL];
        status = xmp_test_module((char *)[moduleURL.path UTF8String], &moduleTestInfo);
        if(status != 0)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Cannot load module."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            return;
        }
        
        [ourModule setFilePath:[ourPanel URL]];
        [ourModule setModuleName:[NSString stringWithFormat:@"%s", moduleTestInfo.name]];
        [ourModule setModuleType:[NSString stringWithFormat:@"%s", moduleTestInfo.type]];
        [ourPlaylist addModule:ourModule];
        [playlistTable reloadData];
    }
    
}

-(IBAction)dumpPlaylist:(id)sender
{
    [ourPlaylist dumpPlaylist];
}

-(IBAction)removeFromPlaylist:(id)sender
{
    if (currentRow >= 0)
    {
        [ourPlaylist removeModuleAtIndex:currentRow];
        [playlistTable reloadData];
    }
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

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = notification.object;
    currentRow = tableView.selectedRow;
}
@end
