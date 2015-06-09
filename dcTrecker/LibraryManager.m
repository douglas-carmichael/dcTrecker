//
//  LibraryManager.m
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "LibraryManager.h"

@implementation LibraryManager

@synthesize currentLibrary = _currentLibrary;

+(id)sharedLibrary
{
    static LibraryManager *sharedPlaylist = nil;
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
        libraryArray = [[NSMutableArray alloc] init];
        _currentLibrary = nil;
    }
    return self;
}

-(void)clearLibrary:(BOOL)clearCurrentProperty
{
    [libraryArray removeAllObjects];
    if (clearCurrentProperty == YES)
    {
        _currentLibrary = nil;
    }
}

-(BOOL)addModule:(Module *)moduleToAdd
{
    xmp_context our_context;
    struct xmp_module_info pModuleInfo;
    int status;
    
    our_context = xmp_create_context();
    status = xmp_load_module(our_context, (char *)[[moduleToAdd.filePath path] UTF8String]);
    if(status != 0)
    {
        return NO;
    }
    
    xmp_get_module_info(our_context, &pModuleInfo);
    xmp_release_module(our_context);
    xmp_free_context(our_context);
    
    NSString *moduleName = [NSString stringWithFormat:@"%s", pModuleInfo.mod->name];
    if ([moduleName isEqual: @""])
    {
        moduleName = @"<unnamed>";
    }
    [moduleToAdd setModuleName:moduleName];
    [moduleToAdd setModuleType:[NSString stringWithFormat:@"%s", pModuleInfo.mod->type]];
    [moduleToAdd setModTotalTime:pModuleInfo.seq_data[0].duration];
    [libraryArray addObject:moduleToAdd];
    return YES;
}

-(Module *)getModuleAtIndex:(NSInteger)ourRow
{
    return [libraryArray objectAtIndex:ourRow];
}

-(BOOL)isEmpty
{
    if ([libraryArray count] == 0)
    {
        return YES;
    }
    return NO;
}

-(NSString *)getModuleLength:(NSInteger)ourRow
{
    int ourTime, minutes, seconds;
    
    // Grab the module path from the row in the library
    Module *myModule = [[Module alloc] init];
    myModule = [libraryArray objectAtIndex:ourRow];
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
            if ([self libraryCount] == ourRow)
            {
                [self clearLibrary:YES];
                NSString *notificationName = @"dcT_reloadLibrary";
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
            }
            
            if (ourRow < [self libraryCount])
            {
                [libraryArray removeObjectAtIndex:ourRow];
                NSString *notificationName = @"dcT_reloadLibrary";
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
            }
        }
    }
}


-(BOOL)saveLibrary:(NSURL *)myPlaylist
{
    if ([self isEmpty])
    {
        return NO;
    }
    
    NSXMLElement *libraryRoot = (NSXMLElement *)[NSXMLNode elementWithName:@"dcLibrary"];
    NSXMLDocument *libraryDocument = [[NSXMLDocument alloc] initWithRootElement:libraryRoot];
    [libraryDocument setVersion:@"1.0"];
    [libraryDocument setCharacterEncoding:@"UTF-8"];
    for (Module *PLModule in libraryArray)
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
        
        [libraryRoot addChild:moduleRoot];
    }
    
    NSData *libraryData = [libraryDocument XMLDataWithOptions:NSXMLNodePrettyPrint];
    if(![libraryData writeToFile:myPlaylist.path atomically:YES])
    {
        return NO;
    }
    _currentLibrary = myPlaylist;
    
    return YES;
}


-(BOOL)loadLibrary:(NSURL *)myPlaylist
{
    NSXMLDocument *libraryDocument;
    NSError *err = nil;
    libraryDocument = [[NSXMLDocument alloc] initWithContentsOfURL:myPlaylist
                                                       options:(NSXMLNodePreserveWhitespace|NSXMLDocumentTidyXML) error:&err];
    if (libraryDocument == nil)
    {
        if (err)
        {
            return NO;
        }
    }
        
    NSXMLNode *libraryNode = [libraryDocument rootElement];
    NSMutableString *titleString = nil;
    NSMutableString *urlString = nil;
    NSMutableString *typeString = nil;
    NSMutableString *timeString = nil;
    if ([[libraryNode name] isNotEqualTo:@"dcPlaylist"])
    {
        return NO;
    }
    
    [libraryArray removeAllObjects];
    
    // Check to see if we've got all our nodes in the XML document we loaded
    // NOTE: moduleNodes is important because each member of this NSArray is a module in the library.
    
    NSArray *moduleNodes = [libraryDocument nodesForXPath:@".//Module" error:nil];
    if ([moduleNodes count] == 0)
    {
        return NO;
    }
    
    NSArray *tagPaths = [NSArray arrayWithObjects:@".//modTitle", @".//modURL", @".//modType", @".//modTotalTime", nil];
    
    for (NSString *ourTag in tagPaths)
    {
        if ([self checkForTags:libraryDocument XPathToCheck:ourTag] == NO)
        {
            return NO;
        }
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
        Module *currentLibraryModule = [[Module alloc] init];
        [currentLibraryModule setModuleName:titleString];
        [currentLibraryModule setModuleType:typeString];
        
        
        // Grab the NSURL from the URL string, and check to see if it is valid.
        NSURL *moduleURL = [NSURL URLWithString:urlString];
        if (moduleURL == nil)
        {
            // Return NO because this URL is invalid.
            return NO;
        }
        [currentLibraryModule setFilePath:moduleURL];
        
        // Check to see if the time is a valid integer
        BOOL timeIsValid = [[NSScanner scannerWithString:timeString] scanInt:nil];
        if (timeIsValid)
        {
            NSInteger totalTime = [timeString integerValue];
            [currentLibraryModule setModTotalTime:(int)totalTime];
            [libraryArray addObject:currentLibraryModule];
        }
        else
        {
            return NO;
        }
    }
    _currentLibrary = myPlaylist;
    return YES;
}

-(BOOL)checkForTags:(NSXMLDocument *)ourDocument XPathToCheck:(NSString *)tagPath
{
    NSArray *tagNodes = [ourDocument nodesForXPath:tagPath error:nil];
    if ([tagNodes count] == 0)
    {
        return NO;
    }
    return YES;
};

-(NSInteger)libraryCount
{
    return libraryArray.count;
}

@end
