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

        NSLog(@"moduleRoot: %@", moduleRoot);
        [playlistRoot addChild:moduleRoot];
    }

    NSData *playlistData = [playlistDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    if(![playlistData writeToFile:myPlaylist.path atomically:YES])
    {
        return NO;
    }
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
            NSLog(@"Cannot read XML!");
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
        NSLog(@"Invalid XML file!");
        return NO;
    }
    
    [playlistArray removeAllObjects];
    
    NSArray *moduleNodes = [playlistDoc nodesForXPath:@".//Module" error:nil];
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
    return YES;
}


-(NSInteger)playlistCount
{
    return playlistArray.count;
}

@end
