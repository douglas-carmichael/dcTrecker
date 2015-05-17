//
//  PlaylistManager.m
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "PlaylistManager.h"

@implementation PlaylistManager

@synthesize currentPlaylist = _currentPlaylist;

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
        _currentPlaylist = nil;
    }
    return self;
}

-(void)clearPlaylist
{
    [playlistArray removeAllObjects];
    _currentPlaylist = nil;
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
    int ourTime, minutes, seconds;
    
    // Grab the module path from the row
    Module *myModule = [[Module alloc] init];
    myModule = [playlistArray objectAtIndex:ourRow];
    ourTime = myModule.modTotalTime;
    
    // Convert modTotalTime to a string
    
    if (ourTime == 0)
    {
        minutes = 0;
        seconds = 0;
        NSString *totalTimeString = @"00:00";
        return totalTimeString;
    }
    else
    {
        minutes = ((ourTime + 500) / 60000);
        seconds = ((ourTime + 500) / 1000) % 60;
        
        // If we're on a 64-bit system, NSInteger is a long.
        // From: http://stackoverflow.com/questions/4445173/when-to-use-nsinteger-vs-int
        
#if __LP64__ || TARGET_OS_EMBEDDED || TARGET_OS_IPHONE || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
        NSString *totalTimeString = [[NSString alloc] initWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
        return totalTimeString;
#else
        NSString *totalTimeString = [[NSString alloc] initWithFormat:@"%02d:%02d", minutes, seconds];
        return totalTimeString;
#endif
    }
}

-(void)removeModuleAtIndex:(NSInteger)ourRow
{
    if (ourRow >= 0)
    {
        if ([self isEmpty] == NO)
        {
            if ([self playlistCount] == ourRow)
            {
                [self clearPlaylist];
                NSString *notificationName = @"dcT_ReloadPlaylist";
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
            }
            
            if (ourRow < [self playlistCount])
            {
                [playlistArray removeObjectAtIndex:ourRow];
                NSString *notificationName = @"dcT_ReloadPlaylist";
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
            }
        }
    }
}


-(BOOL)savePlaylist:(NSURL *)myPlaylist
{
    if ([self isEmpty])
    {
        return NO;
    }
    
    NSXMLElement *playlistRoot = (NSXMLElement *)[NSXMLNode elementWithName:@"dcPlaylist"];
    NSXMLDocument *playlistDoc = [[NSXMLDocument alloc] initWithRootElement:playlistRoot];
    [playlistDoc setVersion:@"1.0"];
    [playlistDoc setCharacterEncoding:@"UTF-8"];
    for (Module *PLModule in playlistArray)
    {
        NSXMLElement *moduleRoot = [[NSXMLElement alloc] initWithName:@"Module"];
        [moduleRoot addChild:[NSXMLNode elementWithName:@"modTitle"
                                            stringValue:[PLModule moduleName]]];
        [moduleRoot addChild:[NSXMLNode elementWithName:@"modURL"
                                            stringValue:[PLModule filePath].absoluteString]];
        [moduleRoot addChild:[NSXMLNode elementWithName:@"modType"
                                            stringValue:[PLModule moduleType]]];
        [moduleRoot addChild:[NSXMLNode elementWithName:@"modTotalTime"
                                            stringValue:[NSString stringWithFormat:@"%i", [PLModule modTotalTime]]]];
        
        [playlistRoot addChild:moduleRoot];
    }
    
    NSData *playlistData = [playlistDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    if(![playlistData writeToFile:myPlaylist.path atomically:YES])
    {
        return NO;
    }
    _currentPlaylist = myPlaylist;
    
    return YES;
}


-(BOOL)loadPlaylist:(NSURL *)myPlaylist
{
    NSXMLDocument *playlistDoc;
    NSError *err = nil;
    playlistDoc = [[NSXMLDocument alloc] initWithContentsOfURL:myPlaylist
                                                       options:(NSXMLNodePreserveWhitespace|NSXMLDocumentTidyXML) error:&err];
    if (playlistDoc == nil)
    {
        if (err)
        {
            return NO;
        }
    }
    
    NSXMLNode *playlistNode = [playlistDoc rootElement];
    NSMutableString *titleString = nil;
    NSMutableString *urlString = nil;
    NSMutableString *typeString = nil;
    NSMutableString *timeString = nil;
    if ([[playlistNode name] isNotEqualTo:@"dcPlaylist"])
    {
        return NO;
    }
    
    [playlistArray removeAllObjects];
    
    NSArray *moduleNodes = [playlistDoc nodesForXPath:@".//Module" error:nil];
    if ([moduleNodes count] == 0)
    {
        return NO;
    }
    
    for (NSXMLNode *myModule in moduleNodes)
    {
        NSXMLNode *titleNode = [[myModule nodesForXPath:@".//modTitle" error:nil] objectAtIndex:0];
        NSXMLNode *urlNode = [[myModule nodesForXPath:@".//modURL" error:nil] objectAtIndex:0];
        NSXMLNode *typeNode = [[myModule nodesForXPath:@".//modType" error:nil] objectAtIndex:0];
        NSXMLNode *timeNode = [[myModule nodesForXPath:@".//modTotalTime" error:nil] objectAtIndex:0];
        
        titleString = [[[titleNode stringValue]
                        substringToIndex:[[titleNode stringValue] length]] mutableCopy];
        urlString = [[[urlNode stringValue]
                      substringToIndex:[[urlNode stringValue] length]] mutableCopy];
        typeString = [[[typeNode stringValue]
                       substringToIndex:[[typeNode stringValue] length]] mutableCopy];
        timeString = [[[timeNode stringValue]
                       substringToIndex:[[timeNode stringValue] length]] mutableCopy];
        Module *playlistModule = [[Module alloc] init];
        [playlistModule setModuleName:titleString];
        [playlistModule setModuleType:typeString];
        [playlistModule setFilePath:[NSURL URLWithString:urlString]];
        
        NSInteger totalTime = [timeString integerValue];
        [playlistModule setModTotalTime:(int)totalTime];
        
        [playlistArray addObject:playlistModule];
        
    }
    _currentPlaylist = myPlaylist;
    
    return YES;
}

-(void)loadPlaylistDialog:(NSWindow *)ourWindow
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
        loadSuccess = [self loadPlaylist:[ourPanel URL]];
        if (loadSuccess == NO)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Cannot load playlist."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:ourWindow completionHandler:nil];
            return;
        }
    }
    return;
}


-(void)savePlaylistDialog:(NSWindow *)ourWindow
{
    NSSavePanel *ourPanel = [NSSavePanel savePanel];
    
    [ourPanel setCanCreateDirectories:YES];
    [ourPanel setCanHide:YES];
    if ([ourPanel runModal] == NSModalResponseOK)
    {
        BOOL saveSuccess;
        saveSuccess = [self savePlaylist:[ourPanel URL]];
        if(saveSuccess == NO)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Cannot save playlist."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:ourWindow completionHandler:nil];
            return;
        }
    }
    return;
}

-(void)addToPlaylistDialog:(NSWindow *)ourWindow
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
            [alert beginSheetModalForWindow:ourWindow completionHandler:nil];
            return;
        }
        
        xmp_get_module_info(our_context, &pModuleInfo);
        xmp_release_module(our_context);
        xmp_free_context(our_context);
        
        [myModule setFilePath:[ourPanel URL]];
        [myModule setModuleName:[NSString stringWithFormat:@"%s", pModuleInfo.mod->name]];
        [myModule setModuleType:[NSString stringWithFormat:@"%s", pModuleInfo.mod->type]];
        [myModule setModTotalTime:pModuleInfo.seq_data[0].duration];
        [self addModule:myModule];
        NSString *notificationName = @"dcT_ReloadPlaylist";
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    }
    return;
}

-(NSInteger)playlistCount
{
    return playlistArray.count;
}

@end
