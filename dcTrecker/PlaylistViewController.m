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

-(void)reloadTable
{
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
        xmp_context our_context;
        struct xmp_module_info pModuleInfo;
        int status;
        NSURL *moduleURL = [ourPanel URL];
        
        our_context = xmp_create_context();
        status = xmp_load_module(our_context, (char *)[moduleURL.path UTF8String]);
        if(status != 0)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Cannot load module."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            return;
        }
        
        xmp_get_module_info(our_context, &pModuleInfo);
        xmp_release_module(our_context);
        xmp_free_context(our_context);
        
        [ourModule setFilePath:[ourPanel URL]];
        [ourModule setModuleName:[NSString stringWithFormat:@"%s", pModuleInfo.mod->name]];
        [ourModule setModuleType:[NSString stringWithFormat:@"%s", pModuleInfo.mod->type]];
        [ourModule setModTotalTime:pModuleInfo.seq_data[0].duration];
        [ourPlaylist addModule:ourModule];
        [playlistTable reloadData];
    }
    return;
}

-(IBAction)dumpPlaylist:(id)sender
{
    [ourPlaylist dumpPlaylist];    
}

-(IBAction)savePlaylistButton:(id)sender
{
    BOOL testMe;
    NSURL *testURL = [[NSURL alloc] initFileURLWithPath:@"/Users/dcarmich/test.xml"];
    testMe = [ourPlaylist savePlaylist:testURL];
    return;
}

-(IBAction)loadPlaylistButton:(id)sender
{
    BOOL testMe;
    NSURL *testURL = [[NSURL alloc] initFileURLWithPath:@"/Users/dcarmich/test.xml"];
    testMe = [ourPlaylist loadPlaylist:testURL];
    [playlistTable reloadData];
    return;
}

-(IBAction)removeFromPlaylist:(id)sender
{
    if (currentRow >= 0)
    {
        if ([ourPlaylist isEmpty] == NO)
        {
            [ourPlaylist removeModuleAtIndex:currentRow];
            [playlistTable reloadData];
        }
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
    
    if (currentRow >= 0)
    {
        NSLog(@"Selected row: %li", (long)currentRow);
        
    }
}
@end
