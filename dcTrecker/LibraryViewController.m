//
//  LibraryViewController.m
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "LibraryViewController.h"

@interface LibraryViewController ()

@end

@implementation LibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    ourPlaylist = [LibraryManager sharedLibrary];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"dcT_reloadLibrary" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToPlaylist:) name:@"dcT_addLibrary" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPlaylistButton:)
                                                 name:@"dcT_loadLibrary" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savePlaylistButton:)
                                                 name:@"dcT_saveLibrary" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeFromPlaylist:)
                                                 name:@"dcT_removeLibrary" object:nil];
    
}

-(void)awakeFromNib
{
    [playlistTable setDoubleAction:@selector(doubleClick:)];
    [playlistTable registerForDraggedTypes:[NSArray arrayWithObject:(NSString *)kUTTypeFileURL]];
}

-(void)reloadTable
{
    [playlistTable reloadData];
}

-(void)clearTable
{
    [ourPlaylist clearLibrary:YES];
}

-(NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    
    // Based on example from:
    // http://stackoverflow.com/questions/10308008/nstableview-and-drag-and-drop-from-finder/10309544#10309544
    
    // Get the file URLs from the pasteboard
    NSPasteboard *ourPasteboard = [info draggingPasteboard];
    // List the file type UTIs we want to accept
    NSArray *acceptedTypes = [NSArray arrayWithObject:(NSString *)kUTTypeAudio];
    NSArray *ourURLs = [ourPasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]]
                                                    options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [NSNumber numberWithBool:YES],NSPasteboardURLReadingFileURLsOnlyKey,
                                                             acceptedTypes, NSPasteboardURLReadingContentsConformToTypesKey,
                                                             nil]];
    
    if (ourURLs.count != 1)
    {
        return NSDragOperationNone;
    }
    
    return NSDragOperationCopy;
}

-(BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    // Get the file URLs from the pasteboard
    NSPasteboard *ourPasteboard = [info draggingPasteboard];
    
    NSArray *acceptedTypes = [NSArray arrayWithObject:(NSString *)kUTTypeAudio];
    NSArray *ourURLs = [ourPasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]]
                                                    options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [NSNumber numberWithBool:YES],NSPasteboardURLReadingFileURLsOnlyKey,
                                                             acceptedTypes, NSPasteboardURLReadingContentsConformToTypesKey,
                                                             nil]];
    for (NSURL *myURL in ourURLs)
    {
        Module *myModule = [[Module alloc] init];
        [myModule setFilePath:[myURL filePathURL]];
        BOOL addSuccess = [ourPlaylist addModule:myModule];
        if (addSuccess == NO)
        {
            [playlistTable reloadData];
            return NO;
        }
    }
    
    [playlistTable reloadData];
    return YES;
    
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
    [ourPlaylist clearLibrary:YES];
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
            [alert setMessageText:@"Cannot save library."];
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
        [ourPlaylist clearLibrary:YES];
        loadSuccess = [ourPlaylist loadPlaylist:[ourPanel URL]];
        if (loadSuccess == NO)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Cannot load library."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            return;
        }
        [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[ourPanel URL]];
        [self reloadTable];
    }
    return;
}

-(IBAction)writeModuleButton:(id)sender
{
    xmpWriter *myWriter;
    Module *myModule;
    NSLog(@"current row: %ld", (long)currentRow);
    myWriter = [[xmpWriter alloc] init];
    
    if (currentRow >= 0 && ([ourPlaylist isEmpty] == NO))
    {
        NSSavePanel *ourPanel = [NSSavePanel savePanel];
        [ourPanel setCanCreateDirectories:YES];
        [ourPanel setAllowedFileTypes:[NSArray arrayWithObject:@"wav"]];
        [ourPanel setCanHide:YES];
        if ([ourPanel runModal] == NSModalResponseOK)
        {
            myModule = [ourPlaylist getModuleAtIndex:currentRow];
            [myWriter loadModule:myModule error:nil];
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
                [myWriter writeModuleWAV:[ourPanel URL] error:nil];
                NSArray *audioURL = [NSArray arrayWithObjects:[ourPanel URL], nil];
                [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:audioURL];
            });
        }
    }
    return;
}

-(NSString *)newPlaylistToolTip
{
    return @"Create new library.";
}

-(NSString *)openPlaylistToolTip
{
    return @"Open a saved library.";
}

-(NSString *)savePlaylistToolTip
{
    return @"Save a library to disk.";
}

-(NSString *)addModuleToolTip
{
    return @"Add module to library.";
}

-(NSString *)removeModuleToolTip
{
    return @"Remove selected module from library.";
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

-(void)doubleClick:(id)object
{
    if (currentRow >= 0)
    {
        if ([ourPlaylist isEmpty] == NO)
        {
            NSDictionary *currRowDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithLong:currentRow] forKey:@"currRow"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dcT_playFromLibrary" object:nil userInfo:currRowDict];
        }
    }
    
}

@end
