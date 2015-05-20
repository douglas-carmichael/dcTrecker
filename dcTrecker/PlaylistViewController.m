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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"dcT_reloadPlaylist" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToPlaylist:) name:@"dcT_addPlaylist" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPlaylistButton:)
                                                name:@"dcT_loadPlaylist" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savePlaylistButton:)
                                                 name:@"dcT_savePlaylist" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeFromPlaylist:)
                                                 name:@"dcT_removePlaylist" object:nil];
    
}

-(void)awakeFromNib
{
    [playlistTable setDoubleAction:@selector(doubleClick:)];
}

-(void)reloadTable
{
    [playlistTable reloadData];
}

-(void)clearTable
{
    [ourPlaylist clearPlaylist:YES];
}

-(IBAction)addToPlaylist:(id)sender
{
    NSOpenPanel *ourPanel = [NSOpenPanel openPanel];
    NSArray *moduleTypes = [NSArray arrayWithObjects:@"mod", @"s3m", @"xm", @"it", @"669",
                            @"mdl", @"far", @"mtm", @"med", @"ptm", @"rtm", @"amf", @"gmc",
                            @"psm", @"j2b", @"psm", @"umx", @"amd", @"rad", @"hsc", @"dtm",
                            @"flx", @"okt", nil];
    
    Module *myModule = [[Module alloc] init];
    
    [ourPanel setCanChooseDirectories:NO];
    [ourPanel setCanChooseFiles:YES];
    [ourPanel setCanCreateDirectories:NO];
    [ourPanel setAllowsMultipleSelection:NO];
    [ourPanel setAllowedFileTypes:moduleTypes];
    if ([ourPanel runModal] == NSModalResponseOK)
    {
        [myModule setFilePath:[ourPanel URL]];
        BOOL addSuccess = [ourPlaylist addModule:myModule];
        if(addSuccess == NO)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Cannot load module."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            return;
        }
        [self reloadTable];
    }
    return;
}

-(IBAction)removeFromPlaylist:(id)sender
{
    currentRow = playlistTable.selectedRow;
    if (currentRow >= 0)
    {
        [ourPlaylist removeModuleAtIndex:currentRow];
    }
    return;
}

-(IBAction)newPlaylist:(id)sender
{
    [ourPlaylist clearPlaylist:YES];
    NSString *notificationName = @"dcT_ReloadPlaylist";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    
}

-(IBAction)savePlaylistButton:(id)sender
{
    NSSavePanel *ourPanel = [NSSavePanel savePanel];
    
    [ourPanel setCanCreateDirectories:YES];
    [ourPanel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
    [ourPanel setCanHide:YES];
    
    if ([ourPanel runModal] == NSModalResponseOK)
    {
        BOOL saveSuccess;
        saveSuccess = [ourPlaylist savePlaylist:[ourPanel URL]];
        if(saveSuccess == NO)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Cannot save playlist."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            return;
        }
    }
    return;
}

-(IBAction)loadPlaylistButton:(id)sender
{
    NSOpenPanel *ourPanel = [NSOpenPanel openPanel];
    [ourPanel setCanChooseDirectories:NO];
    [ourPanel setCanChooseFiles:YES];
    [ourPanel setCanCreateDirectories:NO];
    [ourPanel setAllowsMultipleSelection:NO];
    [ourPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"xml", nil]];
    
    if ([ourPanel runModal] == NSModalResponseOK)
    {
        BOOL loadSuccess;
        [ourPlaylist clearPlaylist:YES];
        loadSuccess = [ourPlaylist loadPlaylist:[ourPanel URL]];
        if (loadSuccess == NO)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Cannot load playlist."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            return;
        }
//        [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[ourPanel URL]];
        [self reloadTable];
    }
    return;
}

-(NSString *)newPlaylistToolTip
{
    return @"Create new playlist.";
}

-(NSString *)openPlaylistToolTip
{
    return @"Open a saved playlist.";
}

-(NSString *)savePlaylistToolTip
{
    return @"Save a playlist to disk.";
}

-(NSString *)addModuleToolTip
{
    return @"Add module to playlist.";
}

-(NSString *)removeModuleToolTip
{
    return @"Remove selected module from playlist.";
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
